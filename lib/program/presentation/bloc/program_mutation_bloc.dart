import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/domain.dart';

part 'program_mutation_event.dart';
part 'program_mutation_state.dart';

/// Bloc for mutating [Program] data
@injectable
class ProgramMutationBloc
    extends Bloc<ProgramMutationEvent, ProgramMutationState> {
  /// Creates new [ProgramMutationBloc]
  new({
    required this._createProgram,
  }) : super(const ProgramMutationState()) {
    on<ProgramMutationCreateRequested>(
      _onProgramMutationCreateRequested,
      transformer: sequential(),
    );
  }

  final CreateProgramUseCase _createProgram;

  Future<void> _onProgramMutationCreateRequested(
    ProgramMutationCreateRequested event,
    Emitter<ProgramMutationState> emit,
  ) async {
    emit(state.copyWith(isCreating: true));

    final result = await _createProgram(
      CreateProgramParams(facultyId: event.facultyId, name: event.name),
    );

    final notice = switch (result) {
      AppSuccess(:final data) => ProgramCreatedNotice(data),
      AppFailure(:final exception) => ProgramMutationFailedNotice(
        type: ProgramMutationType.create,
        exception: exception,
        program: null,
      ),
    };
    emit(state.copyWith(isCreating: false, notice: notice));
  }
}
