import 'package:equatable/equatable.dart';
import 'package:sistem_admin/room/domain/entities.dart';

/// Params for updating a [Room]
final class UpdateRoomParams extends Equatable {
  /// Creates new [UpdateRoomParams]
  const new(
    this.room, {
    this.name,
    this.facultyId,
  });

  /// Room that will be updated
  final Room room;

  /// Updated name
  final String? name;

  /// Updated faculty ID
  final String? facultyId;

  @override
  List<Object?> get props => [room, name, facultyId];
}
