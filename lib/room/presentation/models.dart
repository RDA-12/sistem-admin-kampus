import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/room/domain/domain.dart';

/// UI model for [Room]
class RoomUI extends Room {
  /// Creates new [RoomUI]
  const new({
    required super.id,
    required super.facultyId,
    required super.name,
    required this.faculty,
  });

  /// Faculty data of this room
  final Faculty faculty;
}
