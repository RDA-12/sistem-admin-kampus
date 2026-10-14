part of 'program_detail_bloc.dart';

/// State for [ProgramDetailBloc]
sealed class ProgramDetailState extends Equatable {
  /// Creates new [ProgramDetailState]
  const new();

  @override
  List<Object> get props => [];
}

/// Initial state for [ProgramDetailBloc]
final class ProgramDetailInitial extends ProgramDetailState {
  /// Creates new [ProgramDetailInitial]
  const new();
}

/// State when program detail is loading
final class LoadingProgramDetail extends ProgramDetailState {
  /// Creates new [LoadingProgramDetail]
  const new();
}

/// State when program detail is loaded
final class ProgramDetailLoaded extends ProgramDetailState {
  /// Creates new [ProgramDetailLoaded]
  const new({required this.program});

  /// Loaded [ProgramUI] data
  final ProgramUI program;

  @override
  List<Object> get props => [program];
}

/// State when program detail data failed to load
final class ProgramDetailLoadFailed extends ProgramDetailState {
  /// Creates new [ProgramDetailLoadFailed]
  const new({required this.exception});

  /// Exception thrown when program detail failed to load
  final AppException exception;

  @override
  List<Object> get props => [exception];
}
