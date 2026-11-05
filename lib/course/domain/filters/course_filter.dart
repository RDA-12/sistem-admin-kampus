import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/entities.dart';

/// Filter criteria for querying [Course]
final class CourseFilter extends Filter {
  /// Creates new [CourseFilter]
  const new({this.programId});

  /// Optional program ID to filter courses by
  final String? programId;

  @override
  List<Object?> get props => [programId];
}
