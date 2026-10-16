part of 'course_mutation_bloc.dart';

/// Event for [CourseMutationBloc]
sealed class CourseMutationEvent extends Equatable {
  /// Creates new [CourseMutationEvent]
  const new();
}

/// Event for updating a [Course]
final class CourseMutationUpdateRequested extends CourseMutationEvent {
  /// Creates new [CourseMutationUpdateRequested]
  const new({
    required this.course,
    this.code,
    this.name,
    this.semester,
    this.credit,
    this.programId,
  });

  /// [Course] that will be updated
  final Course course;

  /// New code for [course]
  final String? code;

  /// New name for [course]
  final String? name;

  /// New semester for [course]
  final int? semester;

  /// New weight / credit (SKS) for [course]
  final int? credit;

  /// New program ID for [course]
  final String? programId;

  @override
  List<Object?> get props => [course, code, name, semester, credit, programId];
}

/// Event for creating new [Course]
final class CourseMutationCreateRequested extends CourseMutationEvent {
  /// Creates new [CourseMutationCreateRequested]
  const new({
    required this.programId,
    required this.code,
    required this.name,
    required this.semester,
    required this.credit,
  });

  /// ID of the affiliated program
  final String programId;

  /// Code for new [Course]
  final String code;

  /// Name for new [Course]
  final String name;

  /// Semester for new [Course]
  final int semester;

  /// Weight / credit (SKS) for new [Course]
  final int credit;

  @override
  List<Object?> get props => [programId, code, name, semester, credit];
}

/// Event for deleting a [Course]
final class CourseMutationDeleteRequested extends CourseMutationEvent {
  /// Creates new [CourseMutationDeleteRequested]
  const new({required this.course});

  /// [Course] that will be deleted
  final Course course;

  @override
  List<Object?> get props => [course];
}
