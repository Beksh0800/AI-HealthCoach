import '../../../data/models/exercise_model.dart';

enum ExerciseVideoKind {
  youtubeVideo,
  networkVideo,
  youtubeSearch,
  unsupported,
}

class ResolvedExerciseVideo {
  const ResolvedExerciseVideo({
    required this.kind,
    this.originalUrl,
    this.youtubeId,
    this.normalizedUrl,
  });

  final ExerciseVideoKind kind;
  final String? originalUrl;
  final String? youtubeId;
  final String? normalizedUrl;

  bool get isPlayable =>
      kind == ExerciseVideoKind.youtubeVideo ||
      kind == ExerciseVideoKind.networkVideo;
}

class ExerciseVideoResolver {
  ExerciseVideoResolver._();

  static const List<String> _networkVideoExtensions = <String>[
    '.mp4',
    '.m3u8',
    '.mov',
    '.webm',
  ];

  static ResolvedExerciseVideo resolve(String? url, String mediaType) {
    final rawUrl = url?.trim();
    if (rawUrl == null || rawUrl.isEmpty) {
      return const ResolvedExerciseVideo(kind: ExerciseVideoKind.unsupported);
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return ResolvedExerciseVideo(
        kind: ExerciseVideoKind.unsupported,
        originalUrl: rawUrl,
      );
    }

    if (_isYouTubeSearchUri(uri)) {
      return ResolvedExerciseVideo(
        kind: ExerciseVideoKind.youtubeSearch,
        originalUrl: rawUrl,
        normalizedUrl: uri.toString(),
      );
    }

    final youtubeId = _extractYoutubeId(uri);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      return ResolvedExerciseVideo(
        kind: ExerciseVideoKind.youtubeVideo,
        originalUrl: rawUrl,
        youtubeId: youtubeId,
        normalizedUrl: 'https://www.youtube.com/watch?v=$youtubeId',
      );
    }

    if (_isDirectNetworkVideo(uri)) {
      return ResolvedExerciseVideo(
        kind: ExerciseVideoKind.networkVideo,
        originalUrl: rawUrl,
        normalizedUrl: uri.toString(),
      );
    }

    if (mediaType == ExerciseMediaType.youtube) {
      return ResolvedExerciseVideo(
        kind: ExerciseVideoKind.youtubeSearch,
        originalUrl: rawUrl,
        normalizedUrl: uri.toString(),
      );
    }

    return ResolvedExerciseVideo(
      kind: ExerciseVideoKind.unsupported,
      originalUrl: rawUrl,
    );
  }

  static String? youtubeThumbnailById(String? youtubeId,
      {bool mediumQuality = false}) {
    if (youtubeId == null || youtubeId.isEmpty) return null;
    final quality = mediumQuality ? 'mqdefault' : 'hqdefault';
    return 'https://img.youtube.com/vi/$youtubeId/$quality.jpg';
  }

  static bool _isYouTubeSearchUri(Uri uri) {
    final host = uri.host.toLowerCase();
    if (!host.contains('youtube.com')) return false;
    if (uri.path.toLowerCase() != '/results') return false;
    final query = uri.queryParameters['search_query']?.trim() ?? '';
    return query.isNotEmpty;
  }

  static String? _extractYoutubeId(Uri uri) {
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);

    if (host.contains('youtu.be')) {
      return segments.isNotEmpty ? segments.first : null;
    }

    if (!host.contains('youtube.com')) {
      return null;
    }

    final path = uri.path.toLowerCase();
    if (path == '/watch') {
      final id = uri.queryParameters['v'];
      if (id != null && id.isNotEmpty) return id;
    }

    if (path.startsWith('/shorts/')) {
      return segments.length >= 2 ? segments.elementAt(1) : null;
    }

    if (path.startsWith('/embed/')) {
      return segments.length >= 2 ? segments.elementAt(1) : null;
    }

    return null;
  }

  static bool _isDirectNetworkVideo(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return false;

    final path = uri.path.toLowerCase();
    for (final ext in _networkVideoExtensions) {
      if (path.endsWith(ext)) {
        return true;
      }
    }
    return false;
  }
}
