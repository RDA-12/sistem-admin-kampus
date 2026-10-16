part of 'lecturer_detail_bloc.dart';

/// State for [LecturerDetailBloc]
sealed class LecturerDetailState extends Equatable {
  /// Creates new [LecturerDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [LecturerDetailBloc]
final class LecturerDetailInitial extends LecturerDetailState {
  /// Creates new [LecturerDetailInitial]
  const new();
}

/// State when lecturer detail is loading
final class LoadingLecturerDetail extends LecturerDetailState {
  /// Creates new [LoadingLecturerDetail]
  const new();
}

/// State when lecturer detail is loaded
final class LecturerDetailLoaded extends LecturerDetailState {
  /// Creates new [LecturerDetailLoaded]
  const new({required this.lecturer});

  /// Loaded [LecturerUI] data
  final LecturerUI lecturer;

  @override
  List<Object> get props => [lecturer];
}

/// State when lecturer detail data failed to load
final class LecturerDetailLoadFailed extends LecturerDetailState {
  /// Creates new [LecturerDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when lecturer detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
