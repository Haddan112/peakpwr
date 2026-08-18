import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'workout_log.g.dart';

@HiveType(typeId: 1)
class WorkoutLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  double weight;

  @HiveField(3)
  List<int> reps;

  @HiveField(4)
  String day;

  @HiveField(5)
  DateTime date;

  WorkoutLog({
    String? id,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.day,
    required this.date,
  }) : id = id ?? const Uuid().v4();
}