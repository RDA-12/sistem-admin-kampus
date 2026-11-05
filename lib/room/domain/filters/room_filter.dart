import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/entities.dart';

/// Filter criteria for querying [Room]
final class RoomFilter extends Filter {
  /// Creates new [RoomFilter]
  const new({this.facultyId});

  /// Optional faculty ID to filter rooms by
  final String? facultyId;

  @override
  List<Object?> get props => [facultyId];
}
