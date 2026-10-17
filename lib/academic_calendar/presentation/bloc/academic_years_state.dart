part of 'academic_years_bloc.dart';

/// State for [AcademicYearsBloc]
sealed class AcademicYearsState extends Equatable {
  /// Creates new [AcademicYearsState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class AcademicYearsInitial extends AcademicYearsState {
  /// Creates new [AcademicYearsInitial]
  const new();
}

/// State when academic years is being loaded
final class LoadingAcademicYears extends AcademicYearsState {
  /// Creates new [LoadingAcademicYears]
  const new();
}

/// State when academic years is loaded
final class AcademicYearsLoaded extends AcademicYearsState {
  /// Creates new [AcademicYearsLoaded]
  const new(this.data);

  /// Loaded academic years data
  final List<AcademicYear> data;

  @override
  List<Object> get props => [data];
}

/// State when loading academic years fails
final class AcademicYearsFailure extends AcademicYearsState {
  /// Creates new [AcademicYearsFailure]
  const new(this.exception);

  /// Exception returned when failing to load academic years data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
