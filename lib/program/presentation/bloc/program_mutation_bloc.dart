import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/domain.dart';

part 'program_mutation_event.dart';
part 'program_mutation_state.dart';

/// Bloc for mutating [Program] data
@injectable
class ProgramMutationBloc
    extends Bloc<ProgramMutationEvent, ProgramMutationState>
    with AppLoggerMixin {
  /// Creates new [ProgramMutationBloc]
  new({
    required this._createProgram,
    required this._updateProgram,
    required this._deleteProgram,
  }) : super(const ProgramMutationState()) {
    on<ProgramMutationCreateRequested>(
      _onProgramMutationCreateRequested,
      transformer: sequential(),
    );
    on<ProgramMutationUpdateRequested>(
      _onProgramMutationUpdateRequested,
    );
    on<ProgramMutationDeleteRequested>(
      _onProgramMutationDeleteRequested,
    );
  }

  final CreateProgramUseCase _createProgram;
  final UpdateProgramUseCase _updateProgram;
  final DeleteProgramUseCase _deleteProgram;

  Future<void> _onProgramMutationCreateRequested(
    ProgramMutationCreateRequested event,
    Emitter<ProgramMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating program. emit isCreating true',
        extra: {'facultyId': event.facultyId, 'name': event.name},
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createProgram(
        CreateProgramParams(facultyId: event.facultyId, name: event.name),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('program created. emit created notice');
          return ProgramCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create program failed. emit failure notice');
          return ProgramMutationFailedNotice(
            type: ProgramMutationType.create,
            exception: exception,
            program: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onProgramMutationUpdateRequested(
    ProgramMutationUpdateRequested event,
    Emitter<ProgramMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating program. emit updatingIds',
        extra: {'id': event.program.id, 'name': event.name},
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.program.id},
        ),
      );

      final result = await _updateProgram(
        UpdateProgramParams(event.program, name: event.name),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('program updated. emit updated notice');
          return ProgramUpdatedNotice(
            before: event.program,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update program failed. emit failure notice');
          return ProgramMutationFailedNotice(
            type: ProgramMutationType.update,
            exception: exception,
            program: event.program,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.program.id),
        ),
      );
    });
  }

  Future<void> _onProgramMutationDeleteRequested(
    ProgramMutationDeleteRequested event,
    Emitter<ProgramMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting program. emit deletingIds',
        extra: {'id': event.program.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.program.id},
        ),
      );

      final result = await _deleteProgram(event.program);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('program deleted. emit deleted notice');
          return ProgramDeletedNotice(event.program);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete program failed. emit failure notice');
          return ProgramMutationFailedNotice(
            type: ProgramMutationType.delete,
            exception: exception,
            program: event.program,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.program.id),
        ),
      );
    });
  }
}
