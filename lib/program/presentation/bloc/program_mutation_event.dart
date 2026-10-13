part of 'program_mutation_bloc.dart';

/// Event for [ProgramMutationBloc]
sealed class ProgramMutationEvent extends Equatable {
  /// Creates new [ProgramMutationEvent]
  const new();
}

/// Event for updating a [Program]
final class ProgramMutationUpdateRequested extends ProgramMutationEvent {
  /// Creates new [ProgramMutationUpdateRequested]
  const new({required this.program, this.name});

  /// [Program] that will be updated
  final Program program;

  /// New name for [program]
  final String? name;

  @override
  List<Object?> get props => [program, name];
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

/// Event for deleting a [Program]
final class ProgramMutationDeleteRequested extends ProgramMutationEvent {
  /// Creates new [ProgramMutationDeleteRequested]
  const new({required this.program});

  /// [Program] that will be deleted
  final Program program;

  @override
  List<Object?> get props => [program];
}
