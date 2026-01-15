import 'package:flutter/material.dart';

class AnimatedSpeechBubble extends StatefulWidget {
  final String text;
  final double tailX;

  const AnimatedSpeechBubble({
    super.key,
    required this.text,
    required this.tailX,
  });

  @override
  State<AnimatedSpeechBubble> createState() => _AnimatedSpeechBubbleState();
}

class _AnimatedSpeechBubbleState extends State<AnimatedSpeechBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: CustomPaint(
          painter: SpeechBubblePainter(tailX: widget.tailX),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  final double tailX;

  SpeechBubblePainter({required this.tailX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 12),
      const Radius.circular(16),
    );
    canvas.drawRRect(r, paint);

    final path = Path();
    final tx = tailX.clamp(10, size.width - 34).toDouble();

    path.moveTo(tx, size.height - 12);
    path.lineTo(tx + 12, size.height);
    path.lineTo(tx + 24, size.height - 12);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}