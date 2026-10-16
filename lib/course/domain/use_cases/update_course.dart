import 'package:equatable/equatable.dart';
import 'package:sistem_admin/course/domain/entities.dart';

/// Params for updating a [Course]
final class UpdateCourseParams extends Equatable {
  /// Creates new [UpdateCourseParams]
  const new(
    this.course, {
    this.code,
    this.name,
    this.semester,
    this.programId,
  });

  /// Course that will be updated
  final Course course;

  /// Updated code
  final String? code;

  /// Updated name
  final String? name;

  /// Updated semester
  final int? semester;

  /// Updated program ID
  final String? programId;

  @override
  List<Object?> get props => [course, code, name, semester, programId];
}
