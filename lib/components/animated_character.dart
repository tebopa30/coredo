import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedCharacter extends StatefulWidget {
  final String imagePath;

  const AnimatedCharacter({super.key, required this.imagePath});

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();

    // Check if the file is a video
    _isVideo =
        widget.imagePath.toLowerCase().endsWith('.mp4') ||
        widget.imagePath.toLowerCase().endsWith('.mov') ||
        widget.imagePath.toLowerCase().endsWith('.avi');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounce = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      // For videos, don't apply bouncing animation
      return VideoPlayerWidget(videoPath: widget.imagePath);
    } else {
      // For images, apply bouncing animation
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounce.value),
            child: child,
          );
        },
        child: Image.asset(widget.imagePath, fit: BoxFit.contain),
      );
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(widget.videoPath);
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _videoController.value.size.width,
        height: _videoController.value.size.height,
        child: VideoPlayer(_videoController),
      ),
    );
  }
}
