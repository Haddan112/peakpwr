import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gym_log/models/workout_log.dart';
import 'package:gym_log/data/exercise_translations.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/widgets/animated_background.dart';

class DayHistoryDetailScreen extends StatelessWidget {
  final String dayLabel;
  final List<WorkoutLog> logs;
  const DayHistoryDetailScreen({super.key, required this.dayLabel, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: dayLabel,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: AnimatedBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: logs.map((log) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(translateExerciseName(log.exerciseName), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF00C853))),
                subtitle: Text(
                  '${log.weight} kg - Reps: ${log.reps.map((r) {
                    if (r == -1) return 'Failure: Yes';
                    if (r == 0) return 'Failure: No';
                    return r.toString();
                  }).join("/")}',
                  style: TextStyle(color: const Color(0xFF00C853)),
                ),
                trailing: Text(DateFormat('HH:mm').format(log.date), style: TextStyle(color: Colors.grey.shade600)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}