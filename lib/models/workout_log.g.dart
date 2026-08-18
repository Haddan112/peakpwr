// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogAdapter extends TypeAdapter<WorkoutLog> {
  @override
  final int typeId = 1;

  @override
  WorkoutLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLog(
      id: fields[0] as String?,
      exerciseName: fields[1] as String,
      weight: fields[2] as double,
      reps: (fields[3] as List).cast<int>(),
      day: fields[4] as String,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.day)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
