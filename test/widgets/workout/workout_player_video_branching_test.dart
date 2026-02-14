import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/presentation/widgets/video/exercise_video_player.dart';
import 'package:ai_health_coach/presentation/widgets/video/exercise_video_resolver.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
    );
  }

  group('ExerciseVideoPlayer branching', () {
    testWidgets('youtube branch shows youtube placeholder and fullscreen button',
        (tester) async {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/watch?v=abc123xyz00',
        'youtube',
      );

      await tester.pumpWidget(
        wrap(
          ExerciseVideoPlayer(
            resolvedVideo: resolved,
            enablePlayback: false,
            onFullscreenTap: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('video_kind_youtube')), findsOneWidget);
      expect(find.byKey(const Key('video_fullscreen_button')), findsOneWidget);
      expect(find.byKey(const Key('video_search_button')), findsNothing);
    });

    testWidgets('network branch shows network placeholder and fullscreen button',
        (tester) async {
      final resolved = ExerciseVideoResolver.resolve(
        'https://cdn.example.com/video.mp4',
        'image',
      );

      await tester.pumpWidget(
        wrap(
          ExerciseVideoPlayer(
            resolvedVideo: resolved,
            enablePlayback: false,
            onFullscreenTap: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('video_kind_network')), findsOneWidget);
      expect(find.byKey(const Key('video_fullscreen_button')), findsOneWidget);
      expect(find.byKey(const Key('video_search_button')), findsNothing);
    });

    testWidgets('youtube search branch shows in-app search action',
        (tester) async {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/results?search_query=cat+cow+exercise',
        'youtube',
      );

      await tester.pumpWidget(
        wrap(
          ExerciseVideoPlayer(
            resolvedVideo: resolved,
            enablePlayback: false,
            onOpenSearchTap: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('video_kind_search')), findsOneWidget);
      expect(find.byKey(const Key('video_search_button')), findsOneWidget);
      expect(find.byKey(const Key('video_fullscreen_button')), findsNothing);
    });

    testWidgets('unsupported branch shows fallback without fullscreen button',
        (tester) async {
      final resolved = ExerciseVideoResolver.resolve(
        'https://example.com/page',
        'image',
      );

      await tester.pumpWidget(
        wrap(
          ExerciseVideoPlayer(
            resolvedVideo: resolved,
            enablePlayback: false,
            onFullscreenTap: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('video_kind_unsupported')), findsOneWidget);
      expect(find.byKey(const Key('video_fullscreen_button')), findsNothing);
      expect(find.byKey(const Key('video_search_button')), findsNothing);
    });
  });
}
