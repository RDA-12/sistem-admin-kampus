part of 'program_mutation_bloc.dart';

/// Event for [ProgramMutationBloc]
sealed class ProgramMutationEvent extends Equatable {
  /// Creates new [ProgramMutationEvent]
  const new();
}

/// Event for creating new [Program]
final class ProgramMutationCreateRequested extends ProgramMutationEvent {
  /// Creates new [ProgramMutationCreateRequested]
  const new({required this.facultyId, required this.name});

  /// ID of the parent faculty
  final String facultyId;

  /// Name for new [Program]
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}
