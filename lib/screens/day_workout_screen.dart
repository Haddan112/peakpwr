import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_log/data/workout_plan.dart';
import 'package:gym_log/data/exercise_translations.dart';
import 'package:gym_log/models/workout_log.dart';
import 'package:gym_log/widgets/glass_app_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gym_log/widgets/animated_background.dart';
import 'package:gym_log/widgets/gradient_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';

class DayWorkoutScreen extends StatefulWidget {
  final DayPlan dayPlan;
  const DayWorkoutScreen({super.key, required this.dayPlan});

  @override
  State<DayWorkoutScreen> createState() => _DayWorkoutScreenState();
}

class _DayWorkoutScreenState extends State<DayWorkoutScreen> {
  late List<TextEditingController> _weightControllers;
  late List<List<TextEditingController>> _repControllers;
  late List<List<bool>> _failureSwitches;
  late List<bool> _skipped;

  bool _randomFailureEnabled = false;
  List<int> _randomFailureIndices = [];

  final ScrollController _scrollController = ScrollController();
  bool _isNearEnd = false;

  Timer? _restTimer;
  int _restRemaining = 0;
  int _totalRestSeconds = 0;
  bool _isResting = false;

  // مسودات الأيام لحفظ البيانات مؤقتًا
  static final Map<String, Map<String, dynamic>> _drafts = {};

  static const Map<String, List<String>> _eligibleExercises = {
    'Monday': ['Face Pull', 'Lateral Raise', 'Bench Press', 'Close Grip Bench Press'],
    'Thursday': ['Hammer Curl', 'Overhead Triceps Ext', 'Lateral Raise', 'Face Pull', 'Shoulder Press'],
    'Saturday': [
      'Romanian Deadlift', 'Leg Curl', 'Standing Calf Raises',
      'Seated Calf Raises', 'Weighted Crunch', 'Wrist Curl'
    ],
  };

  @override
  void initState() {
    super.initState();
    final exercises = widget.dayPlan.exercises;
    _weightControllers = List.generate(
      exercises.length,
      (_) => TextEditingController(),
    );
    _repControllers = List.generate(
      exercises.length,
      (i) => List.generate(exercises[i].sets, (_) => TextEditingController()),
    );
    _failureSwitches = List.generate(
      exercises.length,
      (i) => List.filled(exercises[i].sets, false),
    );
    _skipped = List.filled(exercises.length, false);

    _loadDraft();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final isNearEnd = (maxScroll - currentScroll) <= 100;
      if (isNearEnd != _isNearEnd) {
        setState(() {
          _isNearEnd = isNearEnd;
        });
      }
    });
  }

  void _saveDraft() {
    _drafts[widget.dayPlan.day] = {
      'weights': _weightControllers.map((c) => c.text).toList(),
      'reps': _repControllers
          .map((list) => list.map((c) => c.text).toList())
          .toList(),
      'failures':
          _failureSwitches.map((list) => List<bool>.from(list)).toList(),
      'skipped': List<bool>.from(_skipped),
      'randomFailureEnabled': _randomFailureEnabled,
      'randomFailureIndices': List<int>.from(_randomFailureIndices),
    };
  }

  void _loadDraft() {
    final exercises = widget.dayPlan.exercises;
    final draft = _drafts[widget.dayPlan.day];

    if (draft == null) {
      // لا توجد مسودة: ضع الأوزان الافتراضية
      for (int i = 0; i < exercises.length; i++) {
        _weightControllers[i].text = exercises[i].defaultWeight.toString();
      }
      return;
    }

    try {
      final weights = draft['weights'] as List;
      for (int i = 0; i < weights.length && i < _weightControllers.length; i++) {
        _weightControllers[i].text = weights[i] as String;
      }
      final reps = draft['reps'] as List;
      for (int i = 0; i < reps.length && i < _repControllers.length; i++) {
        final inner = reps[i] as List;
        for (int j = 0; j < inner.length && j < _repControllers[i].length; j++) {
          _repControllers[i][j].text = inner[j] as String;
        }
      }
      final failures = draft['failures'] as List;
      for (int i = 0; i < failures.length && i < _failureSwitches.length; i++) {
        final inner = failures[i] as List;
        for (int j = 0; j < inner.length && j < _failureSwitches[i].length; j++) {
          _failureSwitches[i][j] = inner[j] as bool;
        }
      }
      final skipped = draft['skipped'] as List;
      for (int i = 0; i < skipped.length && i < _skipped.length; i++) {
        _skipped[i] = skipped[i] as bool;
      }
      _randomFailureEnabled = draft['randomFailureEnabled'] as bool? ?? false;
      _randomFailureIndices =
          List<int>.from(draft['randomFailureIndices'] as List? ?? []);
    } catch (e) {
      // في حالة خطأ، نضع الأوزان الافتراضية
      for (int i = 0; i < exercises.length; i++) {
        _weightControllers[i].text = exercises[i].defaultWeight.toString();
      }
    }
  }

  void _skipExercise(int index) {
    setState(() {
      _skipped[index] = true;
      _weightControllers[index].text =
          widget.dayPlan.exercises[index].defaultWeight.toString();
      for (int j = 0; j < widget.dayPlan.exercises[index].sets; j++) {
        _repControllers[index][j].clear();
        _failureSwitches[index][j] = false;
      }
    });
  }

  void _cancelSkip(int index) => setState(() => _skipped[index] = false);

  void _toggleRandomFailure(bool value) {
    setState(() {
      _randomFailureEnabled = value;
      if (value) {
        final eligibleNames = _eligibleExercises[widget.dayPlan.day] ?? [];
        final exercises = widget.dayPlan.exercises;
        final eligibleIndices = <int>[];
        for (int i = 0; i < exercises.length; i++) {
          if (eligibleNames.contains(exercises[i].name)) {
            eligibleIndices.add(i);
          }
        }
        if (eligibleIndices.isNotEmpty) {
          final rng = Random();
          eligibleIndices.shuffle(rng);
          _randomFailureIndices = eligibleIndices.take(2).toList();
        } else {
          _randomFailureIndices = [];
        }
      } else {
        _randomFailureIndices = [];
      }
    });
  }

  void _startRest(int seconds) {
    _stopRest();
    setState(() {
      _isResting = true;
      _restRemaining = seconds;
      _totalRestSeconds = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restRemaining <= 1) {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
        final player = AudioPlayer();
        player.play(AssetSource('sounds/beep.mp3'));
        HapticFeedback.heavyImpact();
      } else {
        setState(() {
          _restRemaining--;
        });
      }
    });
  }

  void _stopRest() {
    _restTimer?.cancel();
    _restTimer = null;
    if (_isResting) {
      setState(() {
        _isResting = false;
      });
    }
  }

  void _saveAllExercises() {
    final exercises = widget.dayPlan.exercises;
    final box = Hive.box<WorkoutLog>('workout_logs');
    int savedCount = 0;

    for (int i = 0; i < exercises.length; i++) {
      if (_skipped[i]) continue;

      final exercise = exercises[i];
      final weight =
          double.tryParse(_weightControllers[i].text) ?? exercise.defaultWeight;

      final List<int> reps = [];
      for (int setIndex = 0; setIndex < exercise.sets; setIndex++) {
        final isFailureSet = _randomFailureEnabled &&
            _randomFailureIndices.contains(i) &&
            setIndex == exercise.sets - 1;

        if (isFailureSet) {
          reps.add(_failureSwitches[i][setIndex] ? -1 : 0);
        } else {
          int? repVal = int.tryParse(_repControllers[i][setIndex].text);
          if (repVal != null && repVal > 0) {
            reps.add(repVal);
          }
        }
      }

      if (reps.isNotEmpty) {
        final log = WorkoutLog(
          exerciseName: exercise.name,
          weight: weight,
          reps: reps,
          day: widget.dayPlan.day,
          date: DateTime.now(),
        );
        box.add(log);
        savedCount++;
      }
    }

    if (savedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_data_to_save'.tr())),
      );
      return;
    }

    // مسح المسودة بعد الحفظ الناجح
    _drafts.remove(widget.dayPlan.day);

    setState(() {
      for (int i = 0; i < exercises.length; i++) {
        _weightControllers[i].text = exercises[i].defaultWeight.toString();
        for (int j = 0; j < exercises[i].sets; j++) {
          _repControllers[i][j].clear();
          if (_randomFailureEnabled &&
              _randomFailureIndices.contains(i) &&
              j == exercises[i].sets - 1) {
            _failureSwitches[i][j] = false;
          }
        }
        _skipped[i] = false;
      }
    });

    final totalExercises = exercises.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'saved_successfully'.tr(
            namedArgs: {
              'saved': '$savedCount',
              'total': '$totalExercises',
            },
          ),
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B248),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<File> _copyAssetToTemp(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final tempFile = File('${tempDir.path}/$fileName');
    if (!await tempFile.exists()) {
      await tempFile.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return tempFile;
  }

  void _playVideo(String assetPath, String title) async {
    try {
      final tempFile = await _copyAssetToTemp(assetPath);
      if (!mounted) return;
      final controller = VideoPlayerController.file(tempFile);
      await controller.initialize();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.of(ctx).pop();
              },
              child: Text('close'.tr()),
            ),
          ],
        ),
      );
      controller.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_loading_video'.tr(args: ['$e']))),
      );
    }
  }

  @override
  void dispose() {
    // حفظ المسودة قبل الخروج
    _saveDraft();
    _restTimer?.cancel();
    _scrollController.dispose();
    for (var c in _weightControllers) {
      c.dispose();
    }
    for (var list in _repControllers) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  double _calculateProgress() {
    final exercises = widget.dayPlan.exercises;
    final int total = exercises.length;
    int completed = 0;

    for (int i = 0; i < exercises.length; i++) {
      if (_skipped[i]) continue;

      bool allSetsDone = true;
      for (int j = 0; j < exercises[i].sets; j++) {
        final isFailureSet = _randomFailureEnabled &&
            _randomFailureIndices.contains(i) &&
            j == exercises[i].sets - 1;

        if (isFailureSet) {
          if (!_failureSwitches[i][j]) {
            allSetsDone = false;
            break;
          }
        } else {
          final txt = _repControllers[i][j].text.trim();
          if (txt.isEmpty || (int.tryParse(txt) ?? 0) <= 0) {
            allSetsDone = false;
            break;
          }
        }
      }

      if (allSetsDone) completed++;
    }

    return total > 0 ? completed / total : 0.0;
  }

  Color _getRestColor(double fraction) {
    if (fraction > 0.8) return const Color(0xFF00E676);
    if (fraction > 0.6) return const Color(0xFF00B248);
    if (fraction > 0.4) return Colors.yellow;
    if (fraction > 0.2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.dayPlan.exercises;
    final gradient = const LinearGradient(
      colors: [Color(0xFF00E676), Color(0xFF00B248)],
    );
    final progress = _calculateProgress();

    return Scaffold(
      appBar: GlassAppBar(
        title: widget.dayPlan.day.toLowerCase().tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              Text('failure_label'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Checkbox(
                value: _randomFailureEnabled,
                onChanged: (val) => _toggleRandomFailure(val ?? false),
                activeColor: const Color(0xFF00C853),
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF00C853);
                    }
                    return Colors.white30;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('daily_progress'.tr(),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade400)),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00E676)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GradientProgressBar(progress: progress),
                ],
              ),
            ),
            if (_isResting)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B248).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF00E676).withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer,
                          color: Color(0xFF00E676), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'rest_time'
                                  .tr(namedArgs: {'seconds': '$_restRemaining'}),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final fraction =
                                    _restRemaining / _totalRestSeconds;
                                final color = _getRestColor(fraction);
                                return Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Colors.white24,
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: 6,
                                      width: constraints.maxWidth * fraction,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: color,
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.6),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                        onPressed: _stopRest,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isSkipped = _skipped[index];

                  Widget exerciseContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              translateExerciseName(exercise.name),
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                          if (exercise.videoPath != null &&
                              exercise.videoPath!.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('tutorial'.tr(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic)),
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: gradient,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.play_arrow,
                                        color: Colors.white, size: 18),
                                  ),
                                  onPressed: () => _playVideo(
                                      exercise.videoPath!,
                                      translateExerciseName(exercise.name)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('weight_kg'.tr(),
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.grey.shade400)),
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: _weightControllers[index],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              enabled: !isSkipped,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (() {
                          final reps =
                              exercise.targetReps.where((r) => r > 0).toList();
                          final target = reps.isNotEmpty ? reps.first : 0;
                          return 'reps_per_set_value'
                              .tr(namedArgs: {'count': '$target'});
                        })(),
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(exercise.sets, (setIndex) {
                          final showFailureSwitch = _randomFailureEnabled &&
                              _randomFailureIndices.contains(index) &&
                              setIndex == exercise.sets - 1;

                          if (showFailureSwitch) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: _failureSwitches[index][setIndex],
                                  activeColor: const Color(0xFF00C853),
                                  inactiveThumbColor: Colors.red,
                                  inactiveTrackColor: Colors.red.shade100,
                                  onChanged: isSkipped
                                      ? null
                                      : (val) {
                                          setState(() {
                                            _failureSwitches[index][setIndex] =
                                                val;
                                          });
                                        },
                                ),
                                Text('to_failure'.tr(),
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey.shade400)),
                              ],
                            );
                          }
                          return SizedBox(
                            width: 65,
                            child: TextField(
                              controller: _repControllers[index][setIndex],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText:
                                      '${'set'.tr()} ${setIndex + 1}'),
                              enabled: !isSkipped,
                              onChanged: (_) => setState(() {}),
                            ),
                          );
                        }),
                      ),
                      if (!isSkipped) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _startRest(exercise.restTime),
                              icon: const Icon(Icons.timer,
                                  color: Colors.blueAccent),
                              label: Text('rest'.tr(),
                                  style: GoogleFonts.inter(
                                      color: Colors.blueAccent)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _skipExercise(index),
                              icon: const Icon(Icons.skip_next,
                                  color: Colors.orange),
                              label: Text('skip'.tr(),
                                  style: GoogleFonts.inter(
                                      color: Colors.orange)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Stack(
                      children: [
                        AnimatedOpacity(
                          opacity: isSkipped ? 0.4 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: isSkipped,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: exerciseContent,
                            ),
                          ),
                        ),
                        if (isSkipped)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white54),
                              onSelected: (value) => _cancelSkip(index),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: 'cancel',
                                    child: Text('cancel_skip'.tr())),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 20),
        width: _isNearEnd ? 200 : 65,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: _isNearEnd
              ? BorderRadius.circular(18)
              : BorderRadius.circular(32.5),
          gradient: _isNearEnd ? gradient : null,
          color: _isNearEnd ? null : const Color(0xFF1E1E2E),
          boxShadow: _isNearEnd
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: _isNearEnd
            ? ElevatedButton.icon(
                onPressed: _saveAllExercises,
                icon: const Icon(Icons.save, size: 22),
                label: Text('save_all'.tr(),
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.save,
                    color: Color(0xFF00E676), size: 30),
                onPressed: _saveAllExercises,
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}