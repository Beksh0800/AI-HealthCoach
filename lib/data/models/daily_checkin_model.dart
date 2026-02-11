import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for daily check-in data
class DailyCheckIn {
  final String id;
  final String odUid;
  final DateTime date;
  final int painLevel; // 0-10
  final String painLocation; // Where pain is felt
  final int energyLevel; // 1-5
  final int sleepQuality; // 1-5
  final String mood; // happy, neutral, tired, stressed
  final List<String> currentSymptoms;
  final String? notes;
  final DateTime createdAt;

  DailyCheckIn({
    required this.id,
    required this.odUid,
    required this.date,
    required this.painLevel,
    this.painLocation = '',
    required this.energyLevel,
    required this.sleepQuality,
    required this.mood,
    this.currentSymptoms = const [],
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if workout is recommended based on check-in
  bool get isWorkoutRecommended => painLevel < 7;

  /// Get workout intensity suggestion
  String get suggestedIntensity {
    if (painLevel >= 7) return 'rest';
    if (painLevel >= 4 || energyLevel <= 2) return 'light';
    if (energyLevel >= 4 && painLevel <= 2) return 'high';
    return 'moderate';
  }

  Map<String, dynamic> toMap() {
    return {
      'user_uid': odUid,
      'date': Timestamp.fromDate(date),
      'pain_level': painLevel,
      'pain_location': painLocation,
      'energy_level': energyLevel,
      'sleep_quality': sleepQuality,
      'mood': mood,
      'current_symptoms': currentSymptoms,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory DailyCheckIn.fromMap(Map<String, dynamic> map, String id) {
    return DailyCheckIn(
      id: id,
      odUid: map['user_uid'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      painLevel: map['pain_level']?.toInt() ?? 0,
      painLocation: map['pain_location'] ?? '',
      energyLevel: map['energy_level']?.toInt() ?? 3,
      sleepQuality: map['sleep_quality']?.toInt() ?? 3,
      mood: map['mood'] ?? 'neutral',
      currentSymptoms: List<String>.from(map['current_symptoms'] ?? []),
      notes: map['notes'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  DailyCheckIn copyWith({
    String? id,
    String? odUid,
    DateTime? date,
    int? painLevel,
    String? painLocation,
    int? energyLevel,
    int? sleepQuality,
    String? mood,
    List<String>? currentSymptoms,
    String? notes,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      odUid: odUid ?? this.odUid,
      date: date ?? this.date,
      painLevel: painLevel ?? this.painLevel,
      painLocation: painLocation ?? this.painLocation,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      mood: mood ?? this.mood,
      currentSymptoms: currentSymptoms ?? this.currentSymptoms,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

/// Constants for check-in options
class CheckInConstants {
  CheckInConstants._();

  static const List<String> moods = [
    'happy',
    'energized',
    'neutral',
    'tired',
    'stressed',
  ];

  static const Map<String, String> moodLabels = {
    'happy': 'Отлично 😊',
    'energized': 'Энергичный 💪',
    'neutral': 'Нормально 😐',
    'tired': 'Устал 😴',
    'stressed': 'Стресс 😰',
  };

  static const Map<String, String> moodEmojis = {
    'happy': '😊',
    'energized': '💪',
    'neutral': '😐',
    'tired': '😴',
    'stressed': '😰',
  };

  static const List<String> commonSymptoms = [
    'Головная боль',
    'Боль в спине',
    'Скованность в мышцах',
    'Усталость',
    'Тошнота',
    'Головокружение',
  ];

  static const List<String> painLocations = [
    'Нет боли',
    'Шея',
    'Верхняя часть спины',
    'Поясница',
    'Плечи',
    'Колени',
    'Другое',
  ];
}
