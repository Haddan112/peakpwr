import 'package:easy_localization/easy_localization.dart';

/// يحول الاسم الإنجليزي للتمرين إلى اسمه المترجم.
String translateExerciseName(String englishName) {
  const map = {
    'Incline bench press': 'exercise_incline_bench_press',
    'Dumbbell bench press': 'exercise_dumbbell_bench_press',
    'Lat pulldown': 'exercise_lat_pulldown',
    'Barbell row': 'exercise_barbell_row',
    'Dumbbell overhead extension': 'exercise_dumbbell_overhead_extension',
    'Lateral raise': 'exercise_lateral_raise',
    'Barbell curl': 'exercise_barbell_curl',
    'Shrugs': 'exercise_shrugs',
    'Shoulder press': 'exercise_shoulder_press',
    'Cable row': 'exercise_cable_row',
    'Wide grip Cable row': 'exercise_wide_grip_cable_row',
    'Face pull': 'exercise_face_pull',
    'Hammer curl': 'exercise_hammer_curl',
    'Triceps pushdown': 'exercise_triceps_pushdown',
    'Squat': 'exercise_squat',
    'Romanian Deadlift': 'exercise_romanian_deadlift',
    'Leg Press': 'exercise_leg_press',
    'Leg Curl': 'exercise_leg_curl',
    'Standing Calf Raises': 'exercise_standing_calf_raises',
    'Seated Calf Raises': 'exercise_seated_calf_raises',
    'Weighted Crunch': 'exercise_weighted_crunch',
    'Wrist Curl': 'exercise_wrist_curl',
    'Reverse Wrist Curl': 'exercise_reverse_wrist_curl',
  };
  final key = map[englishName];
  return key != null ? key.tr() : englishName;
}