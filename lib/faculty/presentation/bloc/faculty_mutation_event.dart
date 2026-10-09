part of 'faculty_mutation_bloc.dart';

/// Event for [FacultyMutationBloc]
sealed class FacultyMutationEvent extends Equatable {
  /// Creates new [FacultyMutationEvent]
  const new();
}

/// Event for updating a [Faculty]
final class FacultyMutationUpdateRequested extends FacultyMutationEvent {
  /// Creates new [FacultyMutationUpdateRequested]
  const new({required this.faculty, this.name});

  /// [Faculty] that will be updated
  final Faculty faculty;

  /// New name for [faculty]
  final String? name;

  @override
  List<Object?> get props => [faculty, name];
}

/// Event for creating new [Faculty]
final class FacultyMutationCreateRequested extends FacultyMutationEvent {
  /// Creates new [FacultyMutationCreateRequested]
  const new({required this.name});

  /// Name for new [Faculty]
  final String name;

  @override
  List<Object?> get props => [name];
}

/// Event for deleting a [Faculty]
final class FacultyMutationDeleteRequested extends FacultyMutationEvent {
  /// Creates new [FacultyMutationDeleteRequested]
  const new({required this.faculty});

  /// [Faculty] that will be deleted
  final Faculty faculty;

  @override
  List<Object?> get props => [faculty];
}
