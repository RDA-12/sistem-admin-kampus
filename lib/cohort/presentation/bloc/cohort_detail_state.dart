part of 'cohort_detail_bloc.dart';

/// State for [CohortDetailBloc]
sealed class CohortDetailState extends Equatable {
  /// Creates new [CohortDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [CohortDetailBloc]
final class CohortDetailInitial extends CohortDetailState {
  /// Creates new [CohortDetailInitial]
  const new();
}

/// State when cohort detail is loading
final class LoadingCohortDetail extends CohortDetailState {
  /// Creates new [LoadingCohortDetail]
  const new();
}

/// State when cohort detail is loaded
final class CohortDetailLoaded extends CohortDetailState {
  /// Creates new [CohortDetailLoaded]
  const new({required this.cohort});

  /// Loaded [Cohort] data
  final Cohort cohort;

  @override
  List<Object> get props => [cohort];
}

/// State when cohort detail data failed to load
final class CohortDetailLoadFailed extends CohortDetailState {
  /// Creates new [CohortDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when cohort detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
