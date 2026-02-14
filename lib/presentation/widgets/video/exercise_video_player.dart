import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'exercise_video_resolver.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  const ExerciseVideoPlayer({
    super.key,
    required this.resolvedVideo,
    this.fullscreen = false,
    this.onFullscreenTap,
    this.onOpenSearchTap,
    this.enablePlayback = true,
  });

  final ResolvedExerciseVideo resolvedVideo;
  final bool fullscreen;
  final VoidCallback? onFullscreenTap;
  final VoidCallback? onOpenSearchTap;
  final bool enablePlayback;

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final didSourceChange =
        oldWidget.resolvedVideo.kind != widget.resolvedVideo.kind ||
            oldWidget.resolvedVideo.normalizedUrl !=
                widget.resolvedVideo.normalizedUrl ||
            oldWidget.resolvedVideo.youtubeId != widget.resolvedVideo.youtubeId;

    if (didSourceChange || oldWidget.enablePlayback != widget.enablePlayback) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    if (!widget.enablePlayback) return;

    if (widget.resolvedVideo.kind == ExerciseVideoKind.youtubeVideo) {
      final id = widget.resolvedVideo.youtubeId;
      if (id != null && id.isNotEmpty) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: id,
          autoPlay: false,
          params: YoutubePlayerParams(
            mute: false,
            showControls: true,
            showFullscreenButton: false,
            loop: false,
          ),
        );
      }
      return;
    }

    if (widget.resolvedVideo.kind == ExerciseVideoKind.networkVideo) {
      final url = widget.resolvedVideo.normalizedUrl;
      if (url == null || url.isEmpty) return;
      final uri = Uri.tryParse(url);
      if (uri == null) return;

      _videoController = VideoPlayerController.networkUrl(uri);
      _videoController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        allowFullScreen: false,
        aspectRatio: 16 / 9,
      );
    }
  }

  void _disposeControllers() {
    _youtubeController?.close();
    _youtubeController = null;
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.resolvedVideo.kind) {
      case ExerciseVideoKind.youtubeVideo:
        return _buildYoutubePlayer();
      case ExerciseVideoKind.networkVideo:
        return _buildNetworkVideoPlayer();
      case ExerciseVideoKind.youtubeSearch:
        return _buildSearchCard();
      case ExerciseVideoKind.unsupported:
        return _buildUnsupportedCard();
    }
  }

  Widget _buildYoutubePlayer() {
    if (!widget.enablePlayback || _youtubeController == null) {
      return _withFullscreenButton(
        child: _buildPlaceholderCard(
          key: const Key('video_kind_youtube'),
          icon: Icons.ondemand_video,
          title: 'YouTube видео',
        ),
      );
    }

    return _withFullscreenButton(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _youtubeController!,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  Widget _buildNetworkVideoPlayer() {
    if (!widget.enablePlayback || _chewieController == null) {
      return _withFullscreenButton(
        child: _buildPlaceholderCard(
          key: const Key('video_kind_network'),
          icon: Icons.play_circle_fill,
          title: 'Видео',
        ),
      );
    }

    final isReady = _videoController?.value.isInitialized ?? false;
    if (!isReady) {
      return _withFullscreenButton(
        child: const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return _withFullscreenButton(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _withFullscreenButton({required Widget child}) {
    if (widget.onFullscreenTap == null || widget.fullscreen) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            key: const Key('video_fullscreen_button'),
            onPressed: widget.onFullscreenTap,
            icon: const Icon(Icons.fullscreen),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      key: const Key('video_kind_search'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          const Icon(Icons.travel_explore, color: Colors.orange, size: 36),
          const SizedBox(height: 8),
          const Text(
            'Видео доступно через поиск YouTube',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            key: const Key('video_search_button'),
            onPressed: widget.onOpenSearchTap,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Открыть поиск в приложении'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedCard() {
    return _buildPlaceholderCard(
      key: const Key('video_kind_unsupported'),
      icon: Icons.video_library_outlined,
      title: 'Видео недоступно',
    );
  }

  Widget _buildPlaceholderCard({
    required Key key,
    required IconData icon,
    required String title,
  }) {
    return Container(
      key: key,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
