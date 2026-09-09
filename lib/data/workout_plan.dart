class Exercise {
  final String name;
  final double defaultWeight;
  final int sets;
  final List<int> targetReps;
  final String? videoPath;
  final int restTime; // بالثواني

  Exercise({
    required this.name,
    required this.defaultWeight,
    required this.sets,
    required this.targetReps,
    this.videoPath,
    this.restTime = 60, // افتراضي 60 ثانية
  });
}

class DayPlan {
  final String day;
  final List<Exercise> exercises;

  DayPlan({required this.day, required this.exercises});
}

final List<DayPlan> weeklyPlan = [
DayPlan(day: 'Monday', exercises: [
  Exercise(name: 'Face Pull', defaultWeight: 20, sets: 3, targetReps: [15,15,15], videoPath: 'assets/videos/face_pull.mp4', restTime: 60),
  Exercise(name: 'Incline DB Curl', defaultWeight: 8, sets: 3, targetReps: [12,12,12], videoPath: 'assets/videos/incline_db_curl.mp4', restTime: 60),
  Exercise(name: 'Lateral Raise', defaultWeight: 2.5, sets: 2, targetReps: [15,15], videoPath: 'assets/videos/lateral_raise.mp4', restTime: 45),
  Exercise(name: 'Barbell Row', defaultWeight: 22.5, sets: 4, targetReps: [8,8,8,8], videoPath: 'assets/videos/barbell_row.mp4', restTime: 90),
  Exercise(name: 'Lat Pulldown', defaultWeight: 22.5, sets: 4, targetReps: [8,8,8,8], videoPath: 'assets/videos/lat_pulldown.mp4', restTime: 90),
  Exercise(name: 'Incline Bench Press', defaultWeight: 2.5, sets: 4, targetReps: [7,7,7,7], videoPath: 'assets/videos/incline_bench_press.mp4', restTime: 90),
  Exercise(name: 'Bench Press', defaultWeight: 2.5, sets: 4, targetReps: [7,7,7,7], videoPath: 'assets/videos/bench_press.mp4', restTime: 90),
  Exercise(name: 'Close Grip Bench Press', defaultWeight: 2.5, sets: 3, targetReps: [8,8,8], videoPath: 'assets/videos/close_grip_bench_press.mp4', restTime: 90),
]),
DayPlan(day: 'Thursday', exercises: [
  Exercise(name: 'Hammer Curl', defaultWeight: 5, sets: 3, targetReps: [15,15,15], videoPath: 'assets/videos/hammer_curl.mp4', restTime: 60),
  Exercise(name: 'Overhead Triceps Ext', defaultWeight: 5, sets: 3, targetReps: [15,15,15], videoPath: 'assets/videos/dumbbell_overhead_extension.mp4', restTime: 60),
  Exercise(name: 'Lateral Raise', defaultWeight: 2.5, sets: 2, targetReps: [20,20], videoPath: 'assets/videos/lateral_raise.mp4', restTime: 45),
  Exercise(name: 'Seated Row', defaultWeight: 20, sets: 4, targetReps: [12,12,12,12], videoPath: 'assets/videos/cable_row.mp4', restTime: 90),
  Exercise(name: 'Lat Pulldown', defaultWeight: 22.5, sets: 3, targetReps: [15,15,15], videoPath: 'assets/videos/lat_pulldown.mp4', restTime: 90),
  Exercise(name: 'Face Pull', defaultWeight: 20, sets: 3, targetReps: [20,20,20], videoPath: 'assets/videos/face_pull.mp4', restTime: 60),
  Exercise(name: 'Incline Bench Press', defaultWeight: 2.5, sets: 4, targetReps: [10,10,10,10], videoPath: 'assets/videos/incline_bench_press.mp4', restTime: 90),
  Exercise(name: 'Shoulder Press', defaultWeight: 2.5, sets: 4, targetReps: [10,10,10,10], videoPath: 'assets/videos/shoulder_press.mp4', restTime: 90),
]),
  DayPlan(day: 'Saturday', exercises: [
  Exercise(name: 'Squat', defaultWeight: 2.5, sets: 4, targetReps: [8,8,8,8], videoPath: 'assets/videos/squat.mp4', restTime: 120),
  Exercise(name: 'Romanian Deadlift', defaultWeight: 9, sets: 3, targetReps: [10,10,10], videoPath: 'assets/videos/romanian_deadlift.mp4', restTime: 120),
  Exercise(name: 'Leg Press', defaultWeight: 16, sets: 3, targetReps: [12,12,12], videoPath: 'assets/videos/leg_press.mp4', restTime: 90),
  Exercise(name: 'Leg Curl', defaultWeight: 5, sets: 3, targetReps: [12,12,12], videoPath: 'assets/videos/leg_curl.mp4', restTime: 60),
  Exercise(name: 'Standing Calf Raises', defaultWeight: 20, sets: 4, targetReps: [15,15,15,15], videoPath: 'assets/videos/standing_calf_raises.mp4', restTime: 60),
  Exercise(name: 'Seated Calf Raises', defaultWeight: 15, sets: 3, targetReps: [20,20,20], videoPath: 'assets/videos/seated_calf_raises.mp4', restTime: 60),
  Exercise(name: 'Weighted Crunch', defaultWeight: 20, sets: 2, targetReps: [15,15], videoPath: 'assets/videos/weighted_crunch.mp4', restTime: 45),
  Exercise(name: 'Wrist Curl', defaultWeight: 5, sets: 2, targetReps: [15,15], videoPath: 'assets/videos/wrist_curl.mp4', restTime: 45),
  Exercise(name: 'Reverse Wrist Curl', defaultWeight: 30, sets: 2, targetReps: [15,15], videoPath: 'assets/videos/reverse_wrist_curl.mp4', restTime: 45),
]),
];