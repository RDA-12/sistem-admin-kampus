part of 'cohorts_bloc.dart';

/// State for [CohortsBloc]
sealed class CohortsState extends Equatable {
  /// Creates new [CohortsState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class CohortsInitial extends CohortsState {
  /// Creates new [CohortsInitial]
  const new();
}

/// State when cohorts are being loaded
final class LoadingCohorts extends CohortsState {
  /// Creates new [LoadingCohorts]
  const new();
}

/// State when cohorts are loaded
final class CohortsLoaded extends CohortsState {
  /// Creates new [CohortsLoaded]
  const new(this.data);

  /// Loaded cohorts data
  final List<Cohort> data;

  @override
  List<Object> get props => [data];
}

/// State when loading cohorts fails
final class CohortsFailure extends CohortsState {
  /// Creates new [CohortsFailure]
  const new(this.exception);

  /// Exception returned when failing to load cohorts data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
