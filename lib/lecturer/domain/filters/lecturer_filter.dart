import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';

/// Filter criteria for querying [Lecturer]
final class LecturerFilter extends Filter {
  /// Creates new [LecturerFilter]
  const new({this.programId});

  /// Optional program ID to filter lecturers by
  final String? programId;

  @override
  List<Object?> get props => [programId];
}
