import 'package:equatable/equatable.dart';

/// Represent single Course data
class Course extends Equatable {
  /// Creates new [Course]
  const new({
    required this.id,
    required this.programId,
    required this.code,
    required this.name,
    required this.semester,
  });

  /// ID of this course
  final String id;

  /// ID of the affiliated program
  final String programId;

  /// Code of this course
  final String code;

  /// Name of this course
  final String name;

  /// Semester of this course
  final int semester;

  @override
  List<Object?> get props => [id, programId, code, name, semester];
}
