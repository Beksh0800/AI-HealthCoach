import 'package:equatable/equatable.dart';

class Contraindications {
  Contraindications._();

  static const String lumbarHernia = 'lumbar_hernia';
  static const String cervicalHernia = 'cervical_hernia';
  static const String thoracicHernia = 'thoracic_hernia';
  static const String kneeInjury = 'knee_injury';
  static const String ankleInjury = 'ankle_injury';
  static const String shoulderInjury = 'shoulder_injury';
  static const String wristInjury = 'wrist_injury';
  static const String hipInjury = 'hip_injury';
  static const String scoliosis = 'scoliosis';
  static const String hypertension = 'hypertension';
  static const String heartProblems = 'heart_problems';
  static const String pregnancy = 'pregnancy';
  static const String obesity = 'obesity';
  static const String varicose = 'varicose';
  static const String osteoporosis = 'osteoporosis';

  static const Map<String, String> labels = {
    lumbarHernia: 'Грыжа поясничного отдела',
    cervicalHernia: 'Грыжа шейного отдела',
    thoracicHernia: 'Грыжа грудного отдела',
    kneeInjury: 'Травма колена',
    ankleInjury: 'Травма голеностопа',
    shoulderInjury: 'Травма плеча',
    wristInjury: 'Травма запястья',
    hipInjury: 'Травма тазобедренного сустава',
    scoliosis: 'Сколиоз',
    hypertension: 'Гипертония',
    heartProblems: 'Проблемы с сердцем',
    pregnancy: 'Беременность',
    obesity: 'Ожирение высокой степени',
    varicose: 'Варикоз',
    osteoporosis: 'Остеопороз',
  };
}

class TargetMuscles {
  TargetMuscles._();

  static const String back = 'back';
  static const String lowerBack = 'lower_back';
  static const String upperBack = 'upper_back';
  static const String neck = 'neck';
  static const String shoulders = 'shoulders';
  static const String chest = 'chest';
  static const String core = 'core';
  static const String abs = 'abs';
  static const String obliques = 'obliques';
  static const String quadriceps = 'quadriceps';
  static const String hamstrings = 'hamstrings';
  static const String glutes = 'glutes';
  static const String calves = 'calves';
  static const String hipFlexors = 'hip_flexors';
  static const String arms = 'arms';
  static const String triceps = 'triceps';
  static const String biceps = 'biceps';
  static const String forearms = 'forearms';
  static const String fullBody = 'full_body';

  static const Map<String, String> labels = {
    back: 'Спина',
    lowerBack: 'Поясница',
    upperBack: 'Верх спины',
    neck: 'Шея',
    shoulders: 'Плечи',
    chest: 'Грудь',
    core: 'Кор',
    abs: 'Пресс',
    obliques: 'Косые мышцы',
    quadriceps: 'Квадрицепс',
    hamstrings: 'Бицепс бедра',
    glutes: 'Ягодицы',
    calves: 'Икры',
    hipFlexors: 'Сгибатели бедра',
    arms: 'Руки',
    triceps: 'Трицепс',
    biceps: 'Бицепс',
    forearms: 'Предплечья',
    fullBody: 'Все тело',
  };
}

class Equipment {
  Equipment._();

  static const String none = 'none';
  static const String mat = 'mat';
  static const String chair = 'chair';
  static const String wall = 'wall';
  static const String dumbbells = 'dumbbells';
  static const String resistanceBand = 'resistance_band';
  static const String fitball = 'fitball';
  static const String foamRoller = 'foam_roller';

  static const Map<String, String> labels = {
    none: 'Без оборудования',
    mat: 'Коврик',
    chair: 'Стул',
    wall: 'Стена',
    dumbbells: 'Гантели',
    resistanceBand: 'Резинка',
    fitball: 'Фитбол',
    foamRoller: 'Массажный ролик',
  };
}

class ExerciseMediaType {
  ExerciseMediaType._();

  static const String image = 'image';
  static const String gif = 'gif';
  static const String lottie = 'lottie';
  static const String youtube = 'youtube';
}

class Exercise extends Equatable {
  static const List<String> _imageExtensions = <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.bmp',
    '.avif',
    '.heic',
    '.heif',
  ];

  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String type;
  final List<String> targetMuscles;
  final List<String> contraindications;
  final String equipment;
  final int estimatedSeconds;
  final String? videoUrl;
  final String? imageUrl;
  final String mediaType;
  final String? mediaNeutralUrl;
  final String? mediaMaleUrl;
  final String? mediaFemaleUrl;
  final String? source;
  final String? license;

  const Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.type,
    this.targetMuscles = const [],
    this.contraindications = const [],
    this.equipment = Equipment.none,
    this.estimatedSeconds = 60,
    this.videoUrl,
    this.imageUrl,
    this.mediaType = ExerciseMediaType.image,
    this.mediaNeutralUrl,
    this.mediaMaleUrl,
    this.mediaFemaleUrl,
    this.source,
    this.license,
  });

  bool isSafeFor(List<String> userContraindications) {
    for (final contra in userContraindications) {
      if (contraindications.contains(contra)) {
        return false;
      }
    }
    return true;
  }

  static String? sanitizeImageUrl(String? url) {
    final rawUrl = url?.trim();
    if (rawUrl == null || rawUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty ||
        host.contains('youtube.com') ||
        host.contains('youtu.be')) {
      return null;
    }

    final decodedPath = Uri.decodeComponent(uri.path).toLowerCase();
    for (final extension in _imageExtensions) {
      if (decodedPath.endsWith(extension)) {
        return rawUrl;
      }
    }

    if (host == 'img.youtube.com' || host == 'i.ytimg.com') {
      return rawUrl;
    }

    return null;
  }

  static bool isSupportedImageUrl(String? url) => sanitizeImageUrl(url) != null;

  String? resolveImageUrl({String? gender}) {
    final normalizedGender = gender?.trim().toLowerCase();
    final candidates = <String?>[
      if (normalizedGender == 'male') mediaMaleUrl,
      if (normalizedGender == 'female') mediaFemaleUrl,
      mediaNeutralUrl,
      imageUrl,
    ];

    for (final candidate in candidates) {
      final sanitized = sanitizeImageUrl(candidate);
      if (sanitized != null) {
        return sanitized;
      }
    }

    return null;
  }

  String? resolveMediaUrl({String? gender}) {
    final normalizedGender = gender?.trim().toLowerCase();
    if (normalizedGender == 'male' && (mediaMaleUrl?.isNotEmpty ?? false)) {
      return mediaMaleUrl;
    }
    if (normalizedGender == 'female' && (mediaFemaleUrl?.isNotEmpty ?? false)) {
      return mediaFemaleUrl;
    }
    if (mediaNeutralUrl?.isNotEmpty ?? false) {
      return mediaNeutralUrl;
    }
    if (imageUrl?.isNotEmpty ?? false) {
      return imageUrl;
    }
    if (videoUrl?.isNotEmpty ?? false) {
      return videoUrl;
    }
    return null;
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      type: map['type'] ?? 'strength',
      targetMuscles: List<String>.from(map['target_muscles'] ?? const []),
      contraindications: List<String>.from(
        map['contraindications'] ?? const [],
      ),
      equipment: map['equipment'] ?? Equipment.none,
      estimatedSeconds: map['estimated_seconds']?.toInt() ?? 60,
      videoUrl: map['video_url'],
      imageUrl: map['image_url'],
      mediaType: map['media_type'] ?? ExerciseMediaType.image,
      mediaNeutralUrl: map['media_neutral_url'],
      mediaMaleUrl: map['media_male_url'],
      mediaFemaleUrl: map['media_female_url'],
      source: map['source'],
      license: map['license'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'type': type,
      'target_muscles': targetMuscles,
      'contraindications': contraindications,
      'equipment': equipment,
      'estimated_seconds': estimatedSeconds,
      'video_url': videoUrl,
      'image_url': imageUrl,
      'media_type': mediaType,
      'media_neutral_url': mediaNeutralUrl,
      'media_male_url': mediaMaleUrl,
      'media_female_url': mediaFemaleUrl,
      'source': source,
      'license': license,
    };
  }

  Exercise copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? type,
    List<String>? targetMuscles,
    List<String>? contraindications,
    String? equipment,
    int? estimatedSeconds,
    String? videoUrl,
    String? imageUrl,
    String? mediaType,
    String? mediaNeutralUrl,
    String? mediaMaleUrl,
    String? mediaFemaleUrl,
    String? source,
    String? license,
  }) {
    return Exercise(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      contraindications: contraindications ?? this.contraindications,
      equipment: equipment ?? this.equipment,
      estimatedSeconds: estimatedSeconds ?? this.estimatedSeconds,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      mediaNeutralUrl: mediaNeutralUrl ?? this.mediaNeutralUrl,
      mediaMaleUrl: mediaMaleUrl ?? this.mediaMaleUrl,
      mediaFemaleUrl: mediaFemaleUrl ?? this.mediaFemaleUrl,
      source: source ?? this.source,
      license: license ?? this.license,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    difficulty,
    type,
    targetMuscles,
    contraindications,
    equipment,
    estimatedSeconds,
    videoUrl,
    imageUrl,
    mediaType,
    mediaNeutralUrl,
    mediaMaleUrl,
    mediaFemaleUrl,
    source,
    license,
  ];
}
