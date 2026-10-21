part of 'cohort_detail_bloc.dart';

/// Events for [CohortDetailBloc]
sealed class CohortDetailEvent extends Equatable {
  /// Creates new [CohortDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to [Cohort] data changes
final class CohortDetailSubscriptionRequested extends CohortDetailEvent {
  /// Creates new [CohortDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the [Cohort] that will be loaded
  final String id;

  @override
  List<Object> get props => [id];
}
