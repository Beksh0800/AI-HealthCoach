import 'dart:convert';
import 'dart:io';

import 'package:ai_health_coach/data/datasources/initial_exercises.dart';
import 'package:ai_health_coach/data/services/exercise_enrichment_service.dart';

Future<void> main() async {
  final enrichment = ExerciseEnrichmentService();
  final enriched = await enrichment.enrich(initialExercises);

  final output = enriched.map((e) => e.toMap()).toList();
  final jsonText = const JsonEncoder.withIndent('  ').convert(output);
  final file = File('docs/enriched_exercises_export.json');
  await file.create(recursive: true);
  await file.writeAsString(jsonText);

  final filledMedia = enriched.where((e) => (e.resolveMediaUrl() ?? '').isNotEmpty).length;
  stdout.writeln('Exported ${enriched.length} exercises to ${file.path}');
  stdout.writeln('Exercises with media: $filledMedia');
}
