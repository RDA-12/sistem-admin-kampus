import 'package:equatable/equatable.dart';

/// Represent single Program data
class Program extends Equatable {
  /// Creates new [Program]
  const new({
    required this.id,
    required this.facultyId,
    required this.name,
  });

  /// ID of this program
  final String id;

  /// ID of the parent faculty
  final String facultyId;

  /// Name of this program
  final String name;

  @override
  List<Object?> get props => [id, facultyId, name];
}
