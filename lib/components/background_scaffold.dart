import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'package:coredo_app/sound_manager.dart';

class BackgroundScaffold extends StatefulWidget {
  final List<String>? overlayVideos; // 複数候補の動画パス
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;

  const BackgroundScaffold({
    Key? key,
    this.overlayVideos,
    required this.body,
    this.appBar,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  _BackgroundScaffoldState createState() => _BackgroundScaffoldState();
}

class _BackgroundScaffoldState extends State<BackgroundScaffold> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    if (widget.overlayVideos != null && widget.overlayVideos!.isNotEmpty) {
      // 🎲 ランダムで1つ選ぶ（固定選択なら index を指定）
      final random = Random();
      final selectedPath =
          widget.overlayVideos![random.nextInt(widget.overlayVideos!.length)];

      if (selectedPath.toLowerCase().endsWith('.mp4')) {
        _videoController = VideoPlayerController.asset(selectedPath)
          ..setLooping(false)
          ..initialize().then((_) {
            _updateVolume();
            _videoController!.play();
            setState(() {});
          });
      }
    }
    SoundManager().isSoundOn.addListener(_updateVolume);
  }

  void _updateVolume() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.setVolume(SoundManager().isSoundOn.value ? 1.0 : 0.0);
    }
  }

  @override
  void dispose() {
    SoundManager().isSoundOn.removeListener(_updateVolume);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      body: Stack(
        children: [
          // 🎬 選ばれた動画を重ねる
          if (_videoController != null && _videoController!.value.isInitialized)
            Transform.translate(
              offset: const Offset(0, 180),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Transform.scale(
                  scale: 1.7,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            ),
          // 上に重ねる UI
          widget.body,
        ],
      ),
    );
  }
}
