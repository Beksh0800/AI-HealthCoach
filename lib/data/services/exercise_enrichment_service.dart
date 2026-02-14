import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/exercise_model.dart';

class ExerciseEnrichmentService {
  static const String _wrkoutTreeUrl =
      'https://api.github.com/repos/wrkout/exercises.json/git/trees/master?recursive=1';
  static const String _wrkoutRawBase =
      'https://raw.githubusercontent.com/wrkout/exercises.json/master/exercises';
  static const String _exercemusUrl =
      'https://raw.githubusercontent.com/exercemus/exercises/minified/minified-exercises.json';

  List<_ExternalCandidate>? _wrkoutCache;
  List<_ExternalCandidate>? _exercemusCache;

  Future<List<Exercise>> enrich(List<Exercise> baseExercises) async {
    final wrkoutCandidates = await _loadWrkoutCandidates();
    final exercemusCandidates = await _loadExercemusCandidates();

    if (wrkoutCandidates.isEmpty && exercemusCandidates.isEmpty) {
      return baseExercises;
    }

    return baseExercises.map((exercise) {
      final keywords = _keywordsForExercise(exercise);
      final wrkMatch = _findBestMatch(keywords, wrkoutCandidates);
      final exercemusMatch = _findBestMatch(keywords, exercemusCandidates);
      final manualSlug = _manualWrkoutSlugOverrides[exercise.id];
      final manualImageUrl = manualSlug != null ? _wrkoutImageUrl(manualSlug) : null;
      final fallbackVideoSearch = _youtubeSearchUrl(exercise, keywords);

      final imageUrl = manualImageUrl ?? wrkMatch?.imageUrl ?? exercise.imageUrl;
      final videoUrl = exercemusMatch?.videoUrl ?? exercise.videoUrl ?? fallbackVideoSearch;
      final mediaType = videoUrl.isNotEmpty
          ? ExerciseMediaType.youtube
          : imageUrl != null && imageUrl.isNotEmpty
              ? ExerciseMediaType.image
              : exercise.mediaType;

      final sourceParts = <String>{
        if (exercise.source != null && exercise.source!.isNotEmpty) exercise.source!,
        if (wrkMatch?.source != null) wrkMatch!.source!,
        if (exercemusMatch?.source != null) exercemusMatch!.source!,
        if (videoUrl == fallbackVideoSearch) 'youtube/search-fallback',
      };

      final licenseParts = <String>{
        if (exercise.license != null && exercise.license!.isNotEmpty) exercise.license!,
        if (wrkMatch?.license != null) wrkMatch!.license!,
        if (exercemusMatch?.license != null) exercemusMatch!.license!,
        if (videoUrl == fallbackVideoSearch) 'YouTube link (search result)',
      };

      return exercise.copyWith(
        imageUrl: imageUrl,
        mediaNeutralUrl: videoUrl.isNotEmpty
            ? videoUrl
            : (imageUrl ?? exercise.mediaNeutralUrl),
        videoUrl: videoUrl,
        mediaType: mediaType,
        source: sourceParts.isEmpty ? null : sourceParts.join(' + '),
        license: licenseParts.isEmpty ? null : licenseParts.join(' + '),
      );
    }).toList();
  }

  Future<List<_ExternalCandidate>> _loadWrkoutCandidates() async {
    if (_wrkoutCache != null) {
      return _wrkoutCache!;
    }

    try {
      final response = await http.get(Uri.parse(_wrkoutTreeUrl));
      if (response.statusCode != 200) {
        log('ExerciseEnrichmentService: wrkout status ${response.statusCode}');
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tree = (data['tree'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();

      final candidates = <_ExternalCandidate>[];
      for (final node in tree) {
        final path = node['path'] as String? ?? '';
        if (!path.startsWith('exercises/') || !path.endsWith('/exercise.json')) {
          continue;
        }

        final parts = path.split('/');
        if (parts.length < 3) continue;

        final slug = parts[1];
        final normalized = _normalize(slug.replaceAll('_', ' '));
        if (normalized.isEmpty) continue;

        final imageUrl = _wrkoutImageUrl(slug);
        candidates.add(
          _ExternalCandidate(
            searchText: normalized,
            imageUrl: imageUrl,
            source: 'wrkout/exercises.json',
            license: 'Unlicense (public domain)',
          ),
        );
      }

      _wrkoutCache = candidates;
      return candidates;
    } catch (e) {
      log('ExerciseEnrichmentService: wrkout fetch error: $e');
      return const [];
    }
  }

  Future<List<_ExternalCandidate>> _loadExercemusCandidates() async {
    if (_exercemusCache != null) {
      return _exercemusCache!;
    }

    try {
      final response = await http.get(Uri.parse(_exercemusUrl));
      if (response.statusCode != 200) {
        log('ExerciseEnrichmentService: exercemus status ${response.statusCode}');
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawExercises = (data['exercises'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();

      final candidates = <_ExternalCandidate>[];
      for (final exercise in rawExercises) {
        final name = _normalize(_readString(exercise['name']) ?? '');
        if (name.isEmpty) continue;
        final variations = _readStringList(exercise['variations_on']).map(_normalize).join(' ');
        final video = _readString(exercise['video']);

        candidates.add(
          _ExternalCandidate(
            searchText: '$name $variations',
            videoUrl: video,
            source: 'exercemus/exercises',
            license: 'MIT (dataset), media via original source links',
          ),
        );
      }

      _exercemusCache = candidates;
      return candidates;
    } catch (e) {
      log('ExerciseEnrichmentService: exercemus fetch error: $e');
      return const [];
    }
  }

  _ExternalCandidate? _findBestMatch(
    List<String> keywords,
    List<_ExternalCandidate> candidates,
  ) {
    if (keywords.isEmpty || candidates.isEmpty) {
      return null;
    }

    _ExternalCandidate? best;
    var bestScore = 0;

    for (final candidate in candidates) {
      final score = _score(candidate.searchText, keywords);
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }

    return bestScore >= 2 ? best : null;
  }

  int _score(String searchText, List<String> keywords) {
    var score = 0;
    for (final keyword in keywords) {
      if (searchText.contains(keyword)) {
        score += keyword.length >= 5 ? 2 : 1;
      }
    }
    return score;
  }

  List<String> _keywordsForExercise(Exercise exercise) {
    final fromId = exercise.id.split('_').skip(1).join(' ');
    final base = _normalize(fromId)
        .split(' ')
        .where((token) => token.length > 2)
        .toList();
    final overrides = _manualKeywordOverrides[exercise.id] ?? const <String>[];

    return {
      ...base,
      ...overrides.map(_normalize).expand((s) => s.split(' ')).where((t) => t.length > 2),
    }.toList();
  }

  String _wrkoutImageUrl(String slug) {
    final encodedSlug = Uri.encodeComponent(slug);
    return '$_wrkoutRawBase/$encodedSlug/images/0.jpg';
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  String _youtubeSearchUrl(Exercise exercise, List<String> keywords) {
    final queryBase = keywords.take(4).join(' ').trim();
    final query = queryBase.isNotEmpty
        ? '$queryBase exercise tutorial'
        : '${exercise.id.replaceAll('_', ' ')} exercise tutorial';
    return 'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}';
  }

  String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  List<String> _readStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

class _ExternalCandidate {
  final String searchText;
  final String? imageUrl;
  final String? videoUrl;
  final String? source;
  final String? license;

  const _ExternalCandidate({
    required this.searchText,
    this.imageUrl,
    this.videoUrl,
    this.source,
    this.license,
  });
}

const Map<String, List<String>> _manualKeywordOverrides = {
  'lfk_cat_cow': ['cat cow', 'cat stretch'],
  'lfk_glute_bridge': ['glute bridge'],
  'lfk_neck_turns': ['neck rotation'],
  'lfk_bird_dog': ['bird dog', 'quadruped'],
  'lfk_pelvic_tilt': ['pelvic tilt'],
  'lfk_knee_to_chest': ['knee to chest'],
  'lfk_dead_bug': ['dead bug'],
  'lfk_supine_twist': ['supine twist'],
  'lfk_wall_angels': ['wall angel', 'wall slide'],
  'lfk_chin_tuck': ['chin tuck', 'neck retraction'],
  'lfk_shoulder_blade_squeeze': ['scapular squeeze', 'shoulder blade squeeze'],
  'lfk_thoracic_rotation': ['thoracic rotation'],
  'stretch_child_pose': ['child pose'],
  'stretch_forward_fold': ['seated forward fold'],
  'stretch_neck_side': ['neck side stretch'],
  'stretch_chest_door': ['doorway chest stretch'],
  'stretch_hip_flexor': ['hip flexor stretch'],
  'stretch_pigeon': ['pigeon pose', 'pigeon stretch'],
  'stretch_figure_four': ['figure four stretch'],
  'stretch_quad_standing': ['standing quad stretch'],
  'stretch_calf_wall': ['wall calf stretch'],
  'stretch_tricep': ['triceps stretch'],
  'stretch_cat_stretch': ['cat stretch'],
  'stretch_butterfly': ['butterfly stretch'],
  'strength_squats': ['bodyweight squat', 'squat'],
  'strength_pushups_knees': ['knee push up', 'kneeling push up'],
  'strength_plank': ['plank'],
  'strength_glute_kickback': ['glute kickback', 'donkey kick'],
  'strength_wall_sit': ['wall sit', 'wall squat'],
  'strength_superman': ['superman'],
  'strength_lunges': ['lunge'],
  'strength_crunches': ['crunch'],
  'strength_reverse_lunges': ['reverse lunge'],
  'strength_tricep_dips': ['bench dip', 'triceps dip'],
  'strength_side_plank': ['side plank'],
  'strength_calf_raises': ['calf raise'],
  'cardio_marching': ['march in place', 'marching', 'high knee march'],
  'cardio_step_touch': ['step touch'],
  'cardio_low_impact_jacks': ['low impact jumping jack'],
  'cardio_boxer_shuffle': ['boxer shuffle'],
  'cardio_knee_lifts': ['high knees', 'knee lift'],
  'cardio_arm_circles': ['arm circles'],
  'cardio_standing_bicycle': ['standing bicycle crunch'],
  'cardio_heel_taps': ['heel taps', 'alternate heel toucher'],
};

const Map<String, String> _manualWrkoutSlugOverrides = {
  // Directly mapped fallback for exercises that are not present by name.
  'lfk_bird_dog': 'Superman',
  'lfk_chin_tuck': 'Chin_To_Chest_Stretch',
};
