import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_term_mutation_event.dart';
part 'academic_term_mutation_state.dart';

/// Bloc for mutating [AcademicTerm] data
@injectable
class AcademicTermMutationBloc
    extends Bloc<AcademicTermMutationEvent, AcademicTermMutationState>
    with AppLoggerMixin {
  /// Creates new [AcademicTermMutationBloc]
  new({
    required this._createAcademicTerm,
    required this._updateAcademicTerm,
    required this._deleteAcademicTerm,
  }) : super(const AcademicTermMutationState()) {
    on<AcademicTermMutationCreateRequested>(
      _onAcademicTermMutationCreateRequested,
      transformer: sequential(),
    );
    on<AcademicTermMutationUpdateRequested>(
      _onAcademicTermMutationUpdateRequested,
    );
    on<AcademicTermMutationDeleteRequested>(
      _onAcademicTermMutationDeleteRequested,
    );
  }

  final CreateAcademicTermUseCase _createAcademicTerm;
  final UpdateAcademicTermUseCase _updateAcademicTerm;
  final DeleteAcademicTermUseCase _deleteAcademicTerm;

  Future<void> _onAcademicTermMutationCreateRequested(
    AcademicTermMutationCreateRequested event,
    Emitter<AcademicTermMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating academic term. emit isCreating true',
        extra: {
          'academicYearId': event.academicYearId,
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createAcademicTerm(
        CreateAcademicTermParams(
          academicYearId: event.academicYearId,
          name: event.name,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic term created. emit created notice');
          return AcademicTermCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create academic term failed. emit failed notice');
          return AcademicTermMutationFailedNotice(
            type: .create,
            exception: exception,
            academicTerm: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onAcademicTermMutationUpdateRequested(
    AcademicTermMutationUpdateRequested event,
    Emitter<AcademicTermMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating academic term. emit updatingIds',
        extra: {
          'id': event.academicTerm.id,
          'academicYearId': event.academicYearId,
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.academicTerm.id},
        ),
      );

      final result = await _updateAcademicTerm(
        UpdateAcademicTermParams(
          event.academicTerm,
          academicYearId: event.academicYearId,
          name: event.name,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic term updated. emit updated notice');
          return AcademicTermUpdatedNotice(
            before: event.academicTerm,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update academic term failed. emit failed notice');
          return AcademicTermMutationFailedNotice(
            type: .update,
            exception: exception,
            academicTerm: event.academicTerm,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.academicTerm.id),
        ),
      );
    });
  }

  Future<void> _onAcademicTermMutationDeleteRequested(
    AcademicTermMutationDeleteRequested event,
    Emitter<AcademicTermMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting academic term. emit deletingIds',
        extra: {'id': event.academicTerm.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.academicTerm.id},
        ),
      );

      final result = await _deleteAcademicTerm(event.academicTerm);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('academic term deleted. emit deleted notice');
          return AcademicTermDeletedNotice(event.academicTerm);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete academic term failed. emit failed notice');
          return AcademicTermMutationFailedNotice(
            type: .delete,
            exception: exception,
            academicTerm: event.academicTerm,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.academicTerm.id),
        ),
      );
    });
  }
}
