part of 'lecturer_mutation_bloc.dart';

/// Event for [LecturerMutationBloc]
sealed class LecturerMutationEvent extends Equatable {
  /// Creates new [LecturerMutationEvent]
  const new();
}

/// Event for updating a [Lecturer]
final class LecturerMutationUpdateRequested extends LecturerMutationEvent {
  /// Creates new [LecturerMutationUpdateRequested]
  const new({
    required this.lecturer,
    this.name,
    this.pangkatGolongan,
    this.programId,
  });

  /// [Lecturer] that will be updated
  final Lecturer lecturer;

  /// New name for [lecturer]
  final String? name;

  /// New pangkat / golongan for [lecturer]
  final String? pangkatGolongan;

  /// New program ID for [lecturer]
  final String? programId;

  @override
  List<Object?> get props => [lecturer, name, pangkatGolongan, programId];
}

/// Event for creating new [Lecturer]
final class LecturerMutationCreateRequested extends LecturerMutationEvent {
  /// Creates new [LecturerMutationCreateRequested]
  const new({
    required this.programId,
    required this.name,
    required this.pangkatGolongan,
  });

  /// ID of the affiliated program
  final String programId;

  /// Name for new [Lecturer]
  final String name;

  /// Pangkat / golongan for new [Lecturer]
  final String pangkatGolongan;

  @override
  List<Object?> get props => [programId, name, pangkatGolongan];
}

/// Event for deleting a [Lecturer]
final class LecturerMutationDeleteRequested extends LecturerMutationEvent {
  /// Creates new [LecturerMutationDeleteRequested]
  const new({required this.lecturer});

  /// [Lecturer] that will be deleted
  final Lecturer lecturer;

  @override
  List<Object?> get props => [lecturer];
}
