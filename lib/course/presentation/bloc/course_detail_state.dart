part of 'course_detail_bloc.dart';

/// State for [CourseDetailBloc]
sealed class CourseDetailState extends Equatable {
  /// Creates new [CourseDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [CourseDetailBloc]
final class CourseDetailInitial extends CourseDetailState {
  /// Creates new [CourseDetailInitial]
  const new();
}

/// State when course detail is loading
final class LoadingCourseDetail extends CourseDetailState {
  /// Creates new [LoadingCourseDetail]
  const new();
}

/// State when course detail is loaded
final class CourseDetailLoaded extends CourseDetailState {
  /// Creates new [CourseDetailLoaded]
  const new({required this.course});

  /// Loaded [CourseUI] data
  final CourseUI course;

  @override
  List<Object> get props => [course];
}

/// State when course detail data failed to load
final class CourseDetailLoadFailed extends CourseDetailState {
  /// Creates new [CourseDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when course detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
