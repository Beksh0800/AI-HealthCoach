import 'package:equatable/equatable.dart';

/// Константы для противопоказаний
class Contraindications {
  Contraindications._();

  static const String lumbarHernia = 'lumbar_hernia'; // Грыжа поясничного отдела
  static const String cervicalHernia = 'cervical_hernia'; // Грыжа шейного отдела
  static const String thoracicHernia = 'thoracic_hernia'; // Грыжа грудного отдела
  static const String kneeInjury = 'knee_injury'; // Травма колена
  static const String ankleInjury = 'ankle_injury'; // Травма голеностопа
  static const String shoulderInjury = 'shoulder_injury'; // Травма плеча
  static const String wristInjury = 'wrist_injury'; // Травма запястья
  static const String hipInjury = 'hip_injury'; // Травма тазобедренного сустава
  static const String scoliosis = 'scoliosis'; // Сколиоз
  static const String hypertension = 'hypertension'; // Гипертония
  static const String heartProblems = 'heart_problems'; // Проблемы с сердцем
  static const String pregnancy = 'pregnancy'; // Беременность
  static const String obesity = 'obesity'; // Ожирение высокой степени
  static const String varicose = 'varicose'; // Варикоз
  static const String osteoporosis = 'osteoporosis'; // Остеопороз

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

/// Константы для целевых групп мышц
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
    fullBody: 'Всё тело',
  };
}

/// Константы для оборудования
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

/// Модель упражнения для базы данных
class Exercise extends Equatable {
  final String id;
  final String title;
  final String description;
  final String difficulty; // beginner, intermediate, advanced
  final String type; // lfk, stretching, strength, cardio
  final List<String> targetMuscles; // Целевые мышцы
  final List<String> contraindications; // Противопоказания
  final String equipment; // Необходимое оборудование
  final int estimatedSeconds; // Примерное время выполнения
  final String? videoUrl;
  final String? imageUrl;

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
  });

  /// Проверить, подходит ли упражнение для пользователя с данными ограничениями
  bool isSafeFor(List<String> userContraindications) {
    for (final contra in userContraindications) {
      if (contraindications.contains(contra)) {
        return false;
      }
    }
    return true;
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      type: map['type'] ?? 'strength',
      targetMuscles: List<String>.from(map['target_muscles'] ?? []),
      contraindications: List<String>.from(map['contraindications'] ?? []),
      equipment: map['equipment'] ?? Equipment.none,
      estimatedSeconds: map['estimated_seconds']?.toInt() ?? 60,
      videoUrl: map['video_url'],
      imageUrl: map['image_url'],
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
      ];
}
