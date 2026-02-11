import 'recovery_plan_model.dart';

/// Model for post-workout feedback from AI
class PostWorkoutFeedback {
  final String title;
  final String summary;
  final List<String> tips;
  final String nextWorkoutSuggestion;
  final String encouragement;
  final RecoveryPlan? recoveryPlan;

  PostWorkoutFeedback({
    required this.title,
    required this.summary,
    required this.tips,
    required this.nextWorkoutSuggestion,
    required this.encouragement,
    this.recoveryPlan,
  });
}

/// Model for pain-adapted intensity recommendation
class PainAdaptedIntensity {
  final String originalIntensity;
  final String adjustedIntensity;
  final String reason;
  final List<String> problematicAreas;
  final List<String> avoidExerciseTypes;

  PainAdaptedIntensity({
    required this.originalIntensity,
    required this.adjustedIntensity,
    required this.reason,
    required this.problematicAreas,
    required this.avoidExerciseTypes,
  });

  bool get wasAdjusted => originalIntensity != adjustedIntensity;
}
