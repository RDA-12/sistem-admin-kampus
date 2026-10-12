part of 'faculty_detail_bloc.dart';

/// State for [FacultyDetailBloc]
sealed class FacultyDetailState extends Equatable {
  /// Creates new [FacultyDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [FacultyDetailBloc]
final class FacultyDetailInitial extends FacultyDetailState {
  /// Creates new [FacultyDetailInitial]
  const new();
}

/// State when faculty detail is loading
final class LoadingFacultyDetail extends FacultyDetailState {
  /// Creates new [LoadingFacultyDetail]
  const new();
}

/// State when faculty detail is loaded
final class FacultyDetailLoaded extends FacultyDetailState {
  /// Creates new [FacultyDetailLoaded]
  const new({required this.faculty});

  /// Loaded [Faculty] data
  final Faculty faculty;

  @override
  List<Object> get props => [faculty];
}

/// State when faculty detail data failed to load
final class FacultyDetailLoadFailed extends FacultyDetailState {
  /// Creates new [FacultyDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when faculty detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
