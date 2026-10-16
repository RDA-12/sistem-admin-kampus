import 'package:equatable/equatable.dart';
import 'package:sistem_admin/course/domain/entities.dart';

/// Params for creating a [Course]
final class CreateCourseParams extends Equatable {
  /// Creates new [CreateCourseParams]
  const new({
    required this.programId,
    required this.code,
    required this.name,
    required this.semester,
  });

  /// ID of the affiliated program
  final String programId;

  /// Code for the course
  final String code;

  /// Name for the course
  final String name;

  /// Semester for the course
  final int semester;

  @override
  List<Object?> get props => [programId, code, name, semester];
}
