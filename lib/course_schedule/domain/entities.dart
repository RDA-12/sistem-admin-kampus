import 'package:equatable/equatable.dart';

/// Representing single day course schedule
class CourseSchedule extends Equatable {
  /// Creates new [CourseSchedule]
  const new({
    required this.id,
    required this.academicYearId,
    required this.termId,
    required this.name,
    required this.start,
    required this.duration,
    required this.cohortId,
    required this.courseId,
    required this.programId,
    required this.lecturerId,
    required this.roomId,
  });

  /// ID of the course schedule
  final String id;

  /// Academic year this schedule belong to
  final String academicYearId;

  /// Term this schedule belong to
  final String termId;

  /// ID of the program
  final String programId;

  /// Name of the course schedule
  final String name;

  /// When the schedule start, including its time
  final DateTime start;

  /// Duration of this course schedule
  final Duration duration;

  /// ID of the cohort which this course schedule is meant for
  final String cohortId;

  /// ID of the course for this course schedule
  final String courseId;

  /// ID of the lecturer
  final String lecturerId;

  /// ID of the room
  final String roomId;

  // bool overlappedWith(CourseSchedule other) {
  //   final end = start.add(duration);
  // }

  @override
  List<Object?> get props => [
    id,
    academicYearId,
    termId,
    name,
    start,
    duration,
    cohortId,
    courseId,
    programId,
    lecturerId,
    roomId,
  ];
}
