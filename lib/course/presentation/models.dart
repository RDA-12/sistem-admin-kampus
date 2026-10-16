import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// UI model for [Course]
class CourseUI extends Course {
  /// Creates new [CourseUI]
  const new({
    required super.id,
    required super.programId,
    required super.code,
    required super.name,
    required super.semester,
    required super.credit,
    required this.program,
  });

  /// Program data of this course
  final Program program;
}
