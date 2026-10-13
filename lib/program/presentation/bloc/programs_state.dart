part of 'programs_bloc.dart';

/// State for [ProgramsBloc]
sealed class ProgramsState extends Equatable {
  /// Creates new [ProgramsState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state
final class ProgramsInitial extends ProgramsState {
  /// Creates new [ProgramsInitial]
  const new();
}

/// State when programs is being loaded
final class LoadingPrograms extends ProgramsState {
  /// Creates new [LoadingPrograms]
  const new();
}

/// State when programs is loaded
final class ProgramsLoaded extends ProgramsState {
  /// Creates new [ProgramsLoaded]
  const new(this.data);

  /// Loaded programs data
  final List<Program> data;

  @override
  List<Object> get props => [data];
}

/// State when loading programs fail
final class ProgramsFailure extends ProgramsState {
  /// Creates new [ProgramsFailure]
  const new(this.exception);

  /// Exception returned when fail to load programs data
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
