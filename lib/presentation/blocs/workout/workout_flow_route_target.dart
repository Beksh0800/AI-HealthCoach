import 'workout_cubit.dart';

enum WorkoutFlowRouteTarget { generation, preview, player }

extension WorkoutFlowRouteTargetX on WorkoutState {
  WorkoutFlowRouteTarget get routeTarget {
    if (this is WorkoutReady) {
      return WorkoutFlowRouteTarget.preview;
    }

    if (this is WorkoutInProgress ||
        this is WorkoutPainReported ||
        this is WorkoutPainRest ||
        this is WorkoutExerciseReplacing ||
        this is WorkoutCompleted) {
      return WorkoutFlowRouteTarget.player;
    }

    return WorkoutFlowRouteTarget.generation;
  }
}
