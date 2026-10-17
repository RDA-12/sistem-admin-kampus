part of 'academic_years_bloc.dart';

/// Event for [AcademicYearsBloc]
sealed class AcademicYearsEvent extends Equatable {
  /// Creates new [AcademicYearsEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to academic years data changes
final class AcademicYearsSubscriptionRequested extends AcademicYearsEvent {
  /// Creates new [AcademicYearsSubscriptionRequested]
  const new();
}
