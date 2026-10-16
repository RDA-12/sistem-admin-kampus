import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// UI model for [Lecturer]
class LecturerUI extends Lecturer {
  /// Creates new [LecturerUI]
  const new({
    required super.id,
    required super.programId,
    required super.name,
    required super.pangkatGolongan,
    required this.program,
  });

  /// Program data of this lecturer
  final Program program;
}
