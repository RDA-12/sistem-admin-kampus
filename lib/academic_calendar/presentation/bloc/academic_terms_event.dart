part of 'academic_terms_bloc.dart';

/// Event for [AcademicTermsBloc]
sealed class AcademicTermsEvent extends Equatable {
  /// Creates new [AcademicTermsEvent]
  const new();

  @override
  List<Object?> get props => [];
}

/// Event to subscribe to academic terms data changes
final class AcademicTermsSubscriptionRequested extends AcademicTermsEvent {
  /// Creates new [AcademicTermsSubscriptionRequested]
  const new({this.academicYearId});

  /// Optional academic year ID to filter academic terms
  final String? academicYearId;

  @override
  List<Object?> get props => [academicYearId];
}
