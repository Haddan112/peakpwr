import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/models/workout_log.dart';
import 'package:gym_log/data/exercise_translations.dart';
import 'package:gym_log/data/workout_plan.dart';
import 'package:gym_log/screens/day_history_detail_screen.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/widgets/animated_background.dart';
import 'package:gym_log/widgets/glow_progress_circle.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _deleteDayLogs(Box<WorkoutLog> box, String day, DateTime date) {
    final keysToDelete = <int>[];
    for (var entry in box.toMap().entries) {
      final log = entry.value;
      if (log.day == day &&
          log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      box.delete(key);
    }
  }

  void _clearAll(Box<WorkoutLog> box) => box.clear();

  int _plannedExercisesCount(String day) {
    try {
      final plan = weeklyPlan.firstWhere((p) => p.day.toLowerCase() == day.toLowerCase());
      return plan.exercises.length;
    } catch (_) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'history'.tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('clear_all'.tr()),
                  content: Text('confirm_clear_all'.tr()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('close'.tr())),
                    TextButton(
                      onPressed: () {
                        _clearAll(Hive.box<WorkoutLog>('workout_logs'));
                        Navigator.pop(ctx);
                      },
                      child: Text('delete_all'.tr(),
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBackground(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<WorkoutLog>('workout_logs').listenable(),
          builder: (context, Box<WorkoutLog> box, _) {
            if (box.isEmpty) {
              return Center(
                child: Text('no_workouts'.tr(),
                    style: GoogleFonts.inter(color: Colors.grey)),
              );
            }
            final logs = box.values.toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            final grouped = <String, List<WorkoutLog>>{};
            final groupDateKey = <String, DateTime>{};
            for (var log in logs) {
              final key =
                  '${log.day.toLowerCase().tr()} - ${DateFormat('yyyy/MM/dd').format(log.date)}';
              grouped.putIfAbsent(key, () => []).add(log);
              groupDateKey.putIfAbsent(key, () => log.date);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                final logsForDay = entry.value;
                final date = groupDateKey[entry.key]!;
                final originalDay = logsForDay.first.day;
                final translatedDay = originalDay.toLowerCase().tr();

                final planned = _plannedExercisesCount(originalDay);
                final completed = logsForDay.length;
                final progress = (completed / planned).clamp(0.0, 1.0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DayHistoryDetailScreen(
                              dayLabel: entry.key, logs: logsForDay)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      '$translatedDay - ${DateFormat('yyyy/MM/dd').format(date)}',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    // الدائرة والنسبة بجانبها
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GlowProgressCircle(
                                            progress: progress, size: 28),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(progress * 100).toInt()}%',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('delete_entry'.tr()),
                                      content: Text(
                                        'confirm_delete_entry'.tr(args: [
                                          '$translatedDay - ${DateFormat('yyyy/MM/dd').format(date)}'
                                        ]),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx),
                                            child: Text('close'.tr())),
                                        TextButton(
                                          onPressed: () {
                                            _deleteDayLogs(
                                                box, originalDay, date);
                                            Navigator.pop(ctx);
                                          },
                                          child: Text('delete_all'.tr(),
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...logsForDay.take(2).map((log) => ListTile(
                                dense: true,
                                title: Text(
                                    translateExerciseName(log.exerciseName),
                                    style: GoogleFonts.inter(fontSize: 14)),
                                subtitle: Text(
                                  '${log.weight} kg - Reps: ${log.reps.map((r) => r == -1 ? 'F:Yes' : r == 0 ? 'F:No' : r.toString()).join("/")}',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                                trailing: Text(
                                    DateFormat('HH:mm').format(log.date),
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                              )),
                          if (logsForDay.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '... and ${logsForDay.length - 2} more',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}