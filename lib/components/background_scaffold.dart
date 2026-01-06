import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'package:coredo_app/sound_manager.dart';

class BackgroundScaffold extends StatefulWidget {
  final List<String>? overlayVideos;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  final Widget? bottomNavigationBar;

  const BackgroundScaffold({
    super.key,
    this.overlayVideos,
    required this.body,
    this.appBar,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
  });

  @override
  BackgroundScaffoldState createState() => BackgroundScaffoldState();
}

class BackgroundScaffoldState extends State<BackgroundScaffold> {
  VideoPlayerController? _videoController;
  bool _isInitializing = false;
  String? _currentVideoPath;

  @override
  void initState() {
    super.initState();
    SoundManager().isSoundOn.addListener(_updateVolume);
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant BackgroundScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // overlayVideos が変わったら動画も変える
    if (widget.overlayVideos != oldWidget.overlayVideos) {
      _initVideo(forceChange: true);
    }
  }

  Future<void> _initVideo({bool forceChange = false}) async {
    if (_isInitializing) return;

    final videos = widget.overlayVideos;
    if (videos == null || videos.isEmpty) return;

    // ランダム選択（同じ動画なら再初期化しない）
    final nextPath = videos[Random().nextInt(videos.length)];
    if (!forceChange && nextPath == _currentVideoPath && _videoController != null) {
      return;
    }

    _isInitializing = true;
    _currentVideoPath = nextPath;

    // 古いコントローラ破棄
    final old = _videoController;
    _videoController = null;
    if (mounted) setState(() {});

    if (old != null) {
      try {
        await old.pause();
        await old.dispose();
      } catch (_) {}
    }

    final controller = VideoPlayerController.asset(nextPath);
    _videoController = controller;

    try {
      await controller.initialize();
      controller.setLooping(false);
      _updateVolume();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {});
      controller.play();
    } catch (e) {
      debugPrint("Video init error: $e");
      try {
        await controller.dispose();
      } catch (_) {}
      _videoController = null;
      if (mounted) setState(() {});
    } finally {
      _isInitializing = false;
    }
  }

  void _updateVolume() {
    final c = _videoController;
    if (c == null) return;
    if (!c.value.isInitialized) return;

    c.setVolume(SoundManager().isSoundOn.value ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    SoundManager().isSoundOn.removeListener(_updateVolume);

    final c = _videoController;
    _videoController = null;
    if (c != null) {
      c.pause();
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;

    return Scaffold(
      appBar: widget.appBar,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      body: Stack(
        children: [
          // 背景色（動画がない時のフォールバック）
          Container(color: const Color(0xFF1C1F2A)),

          if (controller != null && controller.value.isInitialized)
            Transform.translate(
              offset: const Offset(0, 70),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.scale(
                  scale: 1.1,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          widget.body,
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}