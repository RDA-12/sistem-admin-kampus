part of 'cohort_mutation_bloc.dart';

/// Event for [CohortMutationBloc]
sealed class CohortMutationEvent extends Equatable {
  /// Creates new [CohortMutationEvent]
  const new();
}

/// Event for updating a [Cohort]
final class CohortMutationUpdateRequested extends CohortMutationEvent {
  /// Creates new [CohortMutationUpdateRequested]
  const new({
    required this.cohort,
    this.name,
    this.entryYear,
  });

  /// [Cohort] that will be updated
  final Cohort cohort;

  /// New name for [cohort]
  final String? name;

  /// New entry year for [cohort]
  final int? entryYear;

  @override
  List<Object?> get props => [cohort, name, entryYear];
}

/// Event for creating new [Cohort]
final class CohortMutationCreateRequested extends CohortMutationEvent {
  /// Creates new [CohortMutationCreateRequested]
  const new({
    required this.name,
    required this.entryYear,
  });

  /// Name for new [Cohort]
  final String name;

  /// Entry year for new [Cohort]
  final int entryYear;

  @override
  List<Object?> get props => [name, entryYear];
}

/// Event for deleting a [Cohort]
final class CohortMutationDeleteRequested extends CohortMutationEvent {
  /// Creates new [CohortMutationDeleteRequested]
  const new({required this.cohort});

  /// [Cohort] that will be deleted
  final Cohort cohort;

  @override
  List<Object?> get props => [cohort];
}
