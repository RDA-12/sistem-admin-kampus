part of 'academic_year_detail_bloc.dart';

/// Event for [AcademicYearDetailBloc]
sealed class AcademicYearDetailEvent extends Equatable {
  /// Creates new [AcademicYearDetailEvent]
  const new();

  @override
  List<Object> get props => [];
}

/// Event to subscribe to academic year detail data changes
final class AcademicYearDetailSubscriptionRequested
    extends AcademicYearDetailEvent {
  /// Creates new [AcademicYearDetailSubscriptionRequested]
  const new({required this.id});

  /// ID of the academic year
  final String id;

  @override
  List<Object> get props => [id];
}
