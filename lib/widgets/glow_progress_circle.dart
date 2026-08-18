import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowProgressCircle extends StatelessWidget {
  final double progress;
  final double size;

  const GlowProgressCircle({
    super.key,
    required this.progress,
    this.size = 26,
  });

  Color _getProgressColor(double value) {
    if (value <= 0.2) return Colors.red;
    if (value <= 0.4) return Colors.orange;
    if (value <= 0.6) return Colors.yellow;
    if (value <= 0.8) return const Color(0xFF00B248);
    return const Color(0xFF00E676);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getProgressColor(progress);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlowProgressPainter(
          progress: progress,
          color: color,
          glowColor: color.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _GlowProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  _GlowProgressPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, radius, glowPaint);

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}