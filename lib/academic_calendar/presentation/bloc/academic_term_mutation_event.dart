part of 'academic_term_mutation_bloc.dart';

/// Event for [AcademicTermMutationBloc]
sealed class AcademicTermMutationEvent extends Equatable {
  /// Creates new [AcademicTermMutationEvent]
  const new();
}

/// Event for updating an [AcademicTerm]
final class AcademicTermMutationUpdateRequested
    extends AcademicTermMutationEvent {
  /// Creates new [AcademicTermMutationUpdateRequested]
  const new({
    required this.academicTerm,
    this.academicYearId,
    this.name,
    this.startDate,
    this.endDate,
  });

  /// [AcademicTerm] that will be updated
  final AcademicTerm academicTerm;

  /// New academic year ID for [academicTerm]
  final String? academicYearId;

  /// New name for [academicTerm]
  final String? name;

  /// New start date for [academicTerm]
  final DateTime? startDate;

  /// New end date for [academicTerm]
  final DateTime? endDate;

  @override
  List<Object?> get props => [
    academicTerm,
    academicYearId,
    name,
    startDate,
    endDate,
  ];
}

/// Event for creating new [AcademicTerm]
final class AcademicTermMutationCreateRequested
    extends AcademicTermMutationEvent {
  /// Creates new [AcademicTermMutationCreateRequested]
  const new({
    required this.academicYearId,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  /// Academic year ID for new [AcademicTerm]
  final String academicYearId;

  /// Name for new [AcademicTerm]
  final String name;

  /// Start date for new [AcademicTerm]
  final DateTime startDate;

  /// End date for new [AcademicTerm]
  final DateTime endDate;

  @override
  List<Object?> get props => [academicYearId, name, startDate, endDate];
}

/// Event for deleting an [AcademicTerm]
final class AcademicTermMutationDeleteRequested
    extends AcademicTermMutationEvent {
  /// Creates new [AcademicTermMutationDeleteRequested]
  const new({required this.academicTerm});

  /// [AcademicTerm] that will be deleted
  final AcademicTerm academicTerm;

  @override
  List<Object?> get props => [academicTerm];
}
