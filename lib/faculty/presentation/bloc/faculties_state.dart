part of 'faculties_bloc.dart';

/// State for [FacultiesBloc]
sealed class FacultiesState extends Equatable {
  /// Creates new [FacultiesBloc]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class FacultiesInitial extends FacultiesState {
  /// Creates new [FacultiesInitial]
  const new();
}

/// State when faculties is being loaded
final class LoadingFaculties extends FacultiesState {
  /// Creates new [LoadingFaculties]
  const new();
}

/// State when faculties is loaded
final class FacultiesLoaded extends FacultiesState {
  /// Creates new [FacultiesLoaded]
  const new(this.data);

  /// Loaded faculties data
  final List<Faculty> data;

  @override
  List<Object> get props => [data];
}

/// State when loading faculties fail
final class FacultiesFailure extends FacultiesState {
  /// Creates new [FacultiesFailure]
  const new(this.exception);

  /// Exception returned when fail to load faculties data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
