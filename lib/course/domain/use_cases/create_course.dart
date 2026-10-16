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
    required this.credit,
  });

  /// ID of the affiliated program
  final String programId;

  /// Code for the course
  final String code;

  /// Name for the course
  final String name;

  /// Semester for the course
  final int semester;

  /// Weight / credit (SKS) for the course
  final int credit;

  @override
  List<Object?> get props => [programId, code, name, semester, credit];
}
