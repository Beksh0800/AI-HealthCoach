import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/data/models/exercise_model.dart';
import 'package:ai_health_coach/presentation/widgets/video/exercise_video_resolver.dart';

void main() {
  group('ExerciseVideoResolver.resolve', () {
    test('parses youtu.be url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://youtu.be/abc123xyz00',
        ExerciseMediaType.youtube,
      );

      expect(resolved.kind, ExerciseVideoKind.youtubeVideo);
      expect(resolved.youtubeId, 'abc123xyz00');
    });

    test('parses youtube watch url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/watch?v=abc123xyz00&t=30',
        ExerciseMediaType.youtube,
      );

      expect(resolved.kind, ExerciseVideoKind.youtubeVideo);
      expect(resolved.youtubeId, 'abc123xyz00');
    });

    test('parses youtube shorts url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/shorts/abc123xyz00',
        ExerciseMediaType.youtube,
      );

      expect(resolved.kind, ExerciseVideoKind.youtubeVideo);
      expect(resolved.youtubeId, 'abc123xyz00');
    });

    test('parses youtube embed url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/embed/abc123xyz00',
        ExerciseMediaType.youtube,
      );

      expect(resolved.kind, ExerciseVideoKind.youtubeVideo);
      expect(resolved.youtubeId, 'abc123xyz00');
    });

    test('detects direct mp4 and m3u8', () {
      final mp4 = ExerciseVideoResolver.resolve(
        'https://cdn.example.com/video.mp4',
        ExerciseMediaType.image,
      );
      final m3u8 = ExerciseVideoResolver.resolve(
        'https://cdn.example.com/stream.m3u8',
        ExerciseMediaType.image,
      );

      expect(mp4.kind, ExerciseVideoKind.networkVideo);
      expect(m3u8.kind, ExerciseVideoKind.networkVideo);
    });

    test('detects youtube search url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://www.youtube.com/results?search_query=cat+cow+exercise',
        ExerciseMediaType.youtube,
      );

      expect(resolved.kind, ExerciseVideoKind.youtubeSearch);
    });

    test('returns unsupported for non-video url', () {
      final resolved = ExerciseVideoResolver.resolve(
        'https://example.com/page',
        ExerciseMediaType.image,
      );

      expect(resolved.kind, ExerciseVideoKind.unsupported);
    });
  });
}
