import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/data/models/exercise_model.dart';

void main() {
  group('Exercise image URL sanitization', () {
    test('accepts direct image URL', () {
      final sanitized = Exercise.sanitizeImageUrl(
        'https://cdn.example.com/exercises/cat-cow.jpg',
      );

      expect(sanitized, 'https://cdn.example.com/exercises/cat-cow.jpg');
    });

    test('accepts encoded firebase storage image URL', () {
      final sanitized = Exercise.sanitizeImageUrl(
        'https://firebasestorage.googleapis.com/v0/b/app/o/images%2Fpose.png?alt=media',
      );

      expect(
        sanitized,
        'https://firebasestorage.googleapis.com/v0/b/app/o/images%2Fpose.png?alt=media',
      );
    });

    test('rejects youtube search URL', () {
      final sanitized = Exercise.sanitizeImageUrl(
        'https://www.youtube.com/results?search_query=scapular+exercise',
      );

      expect(sanitized, isNull);
    });

    test('rejects youtube watch URL', () {
      final sanitized = Exercise.sanitizeImageUrl(
        'https://www.youtube.com/watch?v=abc123xyz00',
      );

      expect(sanitized, isNull);
    });

    test(
      'resolveImageUrl skips non-image media URL and falls back to imageUrl',
      () {
        final exercise = Exercise(
          id: 'test',
          title: 'Test',
          description: 'Test',
          difficulty: 'beginner',
          type: 'mobility',
          mediaType: ExerciseMediaType.youtube,
          mediaNeutralUrl:
              'https://www.youtube.com/results?search_query=cat+cow+exercise',
          imageUrl: 'https://cdn.example.com/exercises/cat-cow.webp',
        );

        final resolvedImage = exercise.resolveImageUrl(gender: 'female');
        expect(resolvedImage, 'https://cdn.example.com/exercises/cat-cow.webp');
      },
    );
  });
}
