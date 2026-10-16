part of 'courses_bloc.dart';

/// State of [CoursesBloc]
sealed class CoursesState extends Equatable {
  const new();
}

/// Initial state of [CoursesBloc]
final class CoursesInitial extends CoursesState {
  /// Creates new [CoursesInitial]
  const new();

  @override
  List<Object?> get props => [];
}

/// State when loading courses
final class LoadingCourses extends CoursesState {
  /// Creates new [LoadingCourses]
  const new();

  @override
  List<Object?> get props => [];
}

/// State when courses loaded
final class CoursesLoaded extends CoursesState {
  /// Creates new [CoursesLoaded]
  const new(this.data);

  /// Loaded courses data
  final List<CourseUI> data;

  @override
  List<Object?> get props => [data];
}

/// State when failed loading courses
final class CoursesFailure extends CoursesState {
  /// Creates new [CoursesFailure]
  const new(this.exception);

  /// Exception caused failure
  final AppException exception;

  @override
  List<Object?> get props => [exception];
}
