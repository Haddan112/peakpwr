import 'package:flutter/material.dart';

class GradientProgressBar extends StatelessWidget {
  final double progress; // من 0.0 إلى 1.0

  const GradientProgressBar({super.key, required this.progress});

  Color _getProgressColor(double value) {
    // تعريف نقاط التوقف اللونية
    if (value < 0.25) {
      // من الأحمر (0%) إلى البرتقالي (25%)
      return Color.lerp(Colors.red, Colors.orange, value / 0.25)!;
    } else if (value < 0.5) {
      // من البرتقالي (25%) إلى الأصفر (50%)
      return Color.lerp(Colors.orange, Colors.yellow, (value - 0.25) / 0.25)!;
    } else if (value < 0.75) {
      // من الأصفر (50%) إلى الأخضر الداكن (75%)
      return Color.lerp(Colors.yellow, const Color(0xFF00B248), (value - 0.5) / 0.25)!;
    } else {
      // من الأخضر الداكن (75%) إلى الأخضر الفاتح (100%)
      return Color.lerp(const Color(0xFF00B248), const Color(0xFF00E676), (value - 0.75) / 0.25)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _getProgressColor(progress);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400), // حركة سلسة
                curve: Curves.easeInOut,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: currentColor,
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}