import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/entities.dart';

/// Filter criteria for querying [Program]
final class ProgramFilter extends Filter {
  /// Creates new [ProgramFilter]
  const new({this.facultyId});

  /// Optional faculty ID to filter programs by
  final String? facultyId;

  @override
  List<Object?> get props => [facultyId];
}
