import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:gym_log/widgets/animated_background.dart';

class LowerBodyWarmupScreen extends StatefulWidget {
  const LowerBodyWarmupScreen({super.key});
  @override
  State<LowerBodyWarmupScreen> createState() => _LowerBodyWarmupScreenState();
}

class _LowerBodyWarmupScreenState extends State<LowerBodyWarmupScreen> {
  late List<bool> _completed;
  final List<Map<String, String>> warmupExercises = const [
    {'title': 'Cycle Warmup', 'subtitle': '5 min', 'icon': '🚴'},
    {'title': 'Squat', 'subtitle': '8 reps', 'icon': '🏋️'},
    {'title': 'SUMO TAPS', 'subtitle': '40s', 'icon': '👣'},
    {'title': 'LATERAL LUNGES', 'subtitle': '40s', 'icon': '↔️'},
    {'title': 'INCH WORMS', 'subtitle': '40s', 'icon': '🐛'},
    {'title': 'WIPERS', 'subtitle': '40s', 'icon': '🔄'},
  ];

  @override
  void initState() {
    super.initState();
    _completed = List.filled(warmupExercises.length, false);
  }

  void _markDone(int index) => setState(() => _completed[index] = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'lower_body_warmup'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: AnimatedBackground(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          itemCount: warmupExercises.length,
          itemBuilder: (context, index) {
            final exercise = warmupExercises[index];
            final isDone = _completed[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDone
                      ? [const Color(0xFF00E676).withValues(alpha: 0.15), const Color(0xFF00B248).withValues(alpha: 0.05)]
                      : [const Color(0xFF00E676).withValues(alpha: 0.08), const Color(0xFF00B248).withValues(alpha: 0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: isDone ? const Color(0xFF00E676).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Text(exercise['icon']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise['title']!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(exercise['subtitle']!, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  if (isDone)
                    Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00B248)])),
                      child: const Icon(Icons.check, color: Colors.white, size: 22),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _markDone(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text('done'.tr(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}