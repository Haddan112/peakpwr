import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/data/workout_plan.dart';
import 'package:gym_log/screens/day_workout_screen.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/utils/transitions.dart';
import 'package:gym_log/widgets/animated_background.dart';

class DaysScreen extends StatelessWidget {
  const DaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'workout_days'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: AnimatedBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: weeklyPlan.length,
          itemBuilder: (context, index) {
            final dayPlan = weeklyPlan[index];
            final dayName = dayPlan.day.toLowerCase().tr();
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  slideRoute(DayWorkoutScreen(dayPlan: dayPlan)), // تم استبدال MaterialPageRoute بـ slideRoute
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00E676).withValues(alpha: 0.15),
                        const Color(0xFF00B248).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B248)]),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('exercises_count'.tr(namedArgs: {'count': '${dayPlan.exercises.length}'}), 
                                 style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}