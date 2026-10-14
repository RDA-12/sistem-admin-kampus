import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// UI model for [Program]
class ProgramUI extends Program {
  /// Creates new [ProgramUI]
  const new({
    required super.id,
    required super.facultyId,
    required super.name,
    required this.faculty,
  });

  /// Faculty data of this program
  final Faculty faculty;
}
