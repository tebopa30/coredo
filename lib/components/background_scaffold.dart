import 'package:flutter/material.dart';
import 'animated_character.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final String? overlayImage;

  const BackgroundScaffold({
    super.key,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.overlayImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset('assets/bg1.png', fit: BoxFit.cover),
        ),
        // Overlay Image
        if (overlayImage != null)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: 1.5,
                alignment: Alignment.bottomCenter,
                child: AnimatedCharacter(imagePath: overlayImage!),
              ),
            ),
          ),
        // Scaffold with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}
