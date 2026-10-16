import 'package:equatable/equatable.dart';
import 'package:sistem_admin/room/domain/entities.dart';

/// Params for creating a [Room]
final class CreateRoomParams extends Equatable {
  /// Creates new [CreateRoomParams]
  const new({
    required this.facultyId,
    required this.name,
  });

  /// ID of the parent faculty
  final String facultyId;

  /// Name for the room
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}
