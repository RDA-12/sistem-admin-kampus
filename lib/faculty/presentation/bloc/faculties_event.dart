part of 'faculties_bloc.dart';

/// Event for [FacultiesBloc]
sealed class FacultiesEvent extends Equatable {
  /// Creates new [FacultiesEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to faculties data changes
final class SubscriptionRequested extends FacultiesEvent {
  /// Creates new [SubscriptionRequested]
  const new();
}
