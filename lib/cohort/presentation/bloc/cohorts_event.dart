part of 'cohorts_bloc.dart';

/// Event for [CohortsBloc]
sealed class CohortsEvent extends Equatable {
  /// Creates new [CohortsEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to cohorts data changes
final class CohortsSubscriptionRequested extends CohortsEvent {
  /// Creates new [CohortsSubscriptionRequested]
  const new();
}
