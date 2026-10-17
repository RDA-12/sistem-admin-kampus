part of 'academic_year_detail_bloc.dart';

/// State for [AcademicYearDetailBloc]
sealed class AcademicYearDetailState extends Equatable {
  /// Creates new [AcademicYearDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [AcademicYearDetailBloc]
final class AcademicYearDetailInitial extends AcademicYearDetailState {
  /// Creates new [AcademicYearDetailInitial]
  const new();
}

/// State when academic year detail is loading
final class LoadingAcademicYearDetail extends AcademicYearDetailState {
  /// Creates new [LoadingAcademicYearDetail]
  const new();
}

/// State when academic year detail is loaded
final class AcademicYearDetailLoaded extends AcademicYearDetailState {
  /// Creates new [AcademicYearDetailLoaded]
  const new({
    required this.academicYear,
    this.terms = const [],
  });

  /// Loaded [AcademicYear] data
  final AcademicYear academicYear;

  /// Academic terms related to the academic year
  final List<AcademicTerm> terms;

  @override
  List<Object> get props => [academicYear, terms];
}

/// State when academic year detail data failed to load
final class AcademicYearDetailLoadFailed extends AcademicYearDetailState {
  /// Creates new [AcademicYearDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when academic year detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
