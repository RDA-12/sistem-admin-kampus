part of 'academic_terms_bloc.dart';

/// State for [AcademicTermsBloc]
sealed class AcademicTermsState extends Equatable {
  /// Creates new [AcademicTermsState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class AcademicTermsInitial extends AcademicTermsState {
  /// Creates new [AcademicTermsInitial]
  const new();
}

/// State when academic terms is being loaded
final class LoadingAcademicTerms extends AcademicTermsState {
  /// Creates new [LoadingAcademicTerms]
  const new();
}

/// State when academic terms is loaded
final class AcademicTermsLoaded extends AcademicTermsState {
  /// Creates new [AcademicTermsLoaded]
  const new(this.data);

  /// Loaded academic terms data
  final List<AcademicTerm> data;

  @override
  List<Object> get props => [data];
}

/// State when loading academic terms fails
final class AcademicTermsFailure extends AcademicTermsState {
  /// Creates new [AcademicTermsFailure]
  const new(this.exception);

  /// Exception returned when failing to load academic terms data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
