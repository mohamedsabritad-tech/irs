import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FurnaceRing extends StatelessWidget {
  final double size;
  final double progress;
  final Color color;
  final String label;
  final bool showLabel;

  const FurnaceRing({
    super.key,
    this.size = 48,
    this.progress = 1.0,
    this.color = AppTheme.indigo,
    this.label = 'FC1',
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress, color: color),
          ),
          if (showLabel)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: size * 0.28,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Icon(Icons.filter_vintage, color: color, size: size * 0.45),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 5.0;
    final radius = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
