import 'package:equatable/equatable.dart';

/// Params for creating a program
final class CreateProgramParams extends Equatable {
  /// Creates new [CreateProgramParams]
  const new({required this.facultyId, required this.name});

  /// ID of the parent faculty
  final String facultyId;

  /// Name for the program
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}
