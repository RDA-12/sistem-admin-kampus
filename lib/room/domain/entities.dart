import 'package:equatable/equatable.dart';

/// Represent single Room data
class Room extends Equatable {
  /// Creates new [Room]
  const new({
    required this.id,
    required this.facultyId,
    required this.name,
  });

  /// ID of this room
  final String id;

  /// ID of the parent faculty
  final String facultyId;

  /// Name of this room
  final String name;

  @override
  List<Object?> get props => [id, facultyId, name];
}
