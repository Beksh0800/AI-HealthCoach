import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String? email;
  final MedicalProfile medicalProfile;
  final String goals;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    this.email,
    required this.medicalProfile,
    required this.goals,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'medical_profile': medicalProfile.toMap(),
      'goals': goals,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'],
      medicalProfile: MedicalProfile.fromMap(map['medical_profile'] ?? {}),
      goals: map['goals'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    MedicalProfile? medicalProfile,
    String? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      medicalProfile: medicalProfile ?? this.medicalProfile,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MedicalProfile {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String activityLevel;
  final List<String> injuries;
  final List<String> contraindications;

  MedicalProfile({
    required this.age,
    required this.weight,
    this.height = 170.0,
    this.gender = 'not_specified',
    required this.activityLevel,
    required this.injuries,
    this.contraindications = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activity_level': activityLevel,
      'injuries': injuries,
      'contraindications': contraindications,
    };
  }

  factory MedicalProfile.fromMap(Map<String, dynamic> map) {
    return MedicalProfile(
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 170.0,
      gender: map['gender'] ?? 'not_specified',
      activityLevel: map['activity_level'] ?? '',
      injuries: List<String>.from(map['injuries'] ?? []),
      contraindications: List<String>.from(map['contraindications'] ?? []),
    );
  }

  /// Generate contraindications based on injuries
  static List<String> generateContraindications(
    List<String> injuries,
    Map<String, List<String>> contraindicationsMap,
  ) {
    final contraindications = <String>{};
    for (final injury in injuries) {
      final mappedContraindications = contraindicationsMap[injury];
      if (mappedContraindications != null) {
        contraindications.addAll(mappedContraindications);
      }
    }
    return contraindications.toList();
  }
}
