import 'package:flutter/material.dart';

import '../../widgets/video/exercise_video_player.dart';
import '../../widgets/video/exercise_video_resolver.dart';
import 'exercise_search_webview_page.dart';

class ExerciseVideoFullscreenPage extends StatelessWidget {
  const ExerciseVideoFullscreenPage({
    super.key,
    required this.title,
    required this.resolvedVideo,
  });

  final String title;
  final ResolvedExerciseVideo resolvedVideo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ExerciseVideoPlayer(
                resolvedVideo: resolvedVideo,
                fullscreen: true,
                onOpenSearchTap: () => _openSearch(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    final url = resolvedVideo.normalizedUrl;
    if (url == null || url.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseSearchWebViewPage(
          url: url,
          title: title,
        ),
      ),
    );
  }
}
