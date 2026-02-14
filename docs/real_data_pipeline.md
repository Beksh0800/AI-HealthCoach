# Real Exercise Data Pipeline

This project now enriches exercise media automatically from an open dataset:

- Source: `exercemus/exercises`
- URL: `https://github.com/exercemus/exercises`
- License (repository): MIT
- Dataset includes attribution/license fields per exercise entry

## How it works

1. App loads exercises from Firestore (`exercises_library`) if available.
2. If Firestore is empty/unavailable, app uses local `initial_exercises`.
3. `ExerciseEnrichmentService` fetches open dataset JSON and maps media to your exercise IDs.
4. Gender strategy:
   - Use gender-specific media if available
   - Fallback to neutral media
   - Fallback to existing image/video fields

## Export enriched JSON

Run:

```bash
dart run tool/export_enriched_exercises.dart
```

Output file:

- `docs/enriched_exercises_export.json`

You can use this file as a base for Firestore seeding.
