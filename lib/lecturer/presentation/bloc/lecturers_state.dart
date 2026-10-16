part of 'lecturers_bloc.dart';

/// State for [LecturersBloc]
sealed class LecturersState extends Equatable {
  /// Creates new [LecturersState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class LecturersInitial extends LecturersState {
  /// Creates new [LecturersInitial]
  const new();
}

/// State when lecturers is being loaded
final class LoadingLecturers extends LecturersState {
  /// Creates new [LoadingLecturers]
  const new();
}

/// State when lecturers is loaded
final class LecturersLoaded extends LecturersState {
  /// Creates new [LecturersLoaded]
  const new(this.data);

  /// Loaded lecturers data
  final List<LecturerUI> data;

  @override
  List<Object> get props => [data];
}

/// State when loading lecturers fail
final class LecturersFailure extends LecturersState {
  /// Creates new [LecturersFailure]
  const new(this.exception);

  /// Exception returned when fail to load lecturers data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
