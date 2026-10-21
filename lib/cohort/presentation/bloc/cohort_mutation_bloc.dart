import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'cohort_mutation_event.dart';
part 'cohort_mutation_state.dart';

/// Bloc for mutating [Cohort] data
@injectable
class CohortMutationBloc extends Bloc<CohortMutationEvent, CohortMutationState>
    with AppLoggerMixin {
  /// Creates new [CohortMutationBloc]
  new({
    required this._createCohort,
    required this._updateCohort,
    required this._deleteCohort,
  }) : super(const CohortMutationState()) {
    on<CohortMutationCreateRequested>(
      _onCohortMutationCreateRequested,
      transformer: sequential(),
    );
    on<CohortMutationUpdateRequested>(
      _onCohortMutationUpdateRequested,
    );
    on<CohortMutationDeleteRequested>(
      _onCohortMutationDeleteRequested,
    );
  }

  final CreateCohortUseCase _createCohort;
  final UpdateCohortUseCase _updateCohort;
  final DeleteCohortUseCase _deleteCohort;

  Future<void> _onCohortMutationCreateRequested(
    CohortMutationCreateRequested event,
    Emitter<CohortMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating cohort. emit isCreating true',
        extra: {
          'name': event.name,
          'entryYear': event.entryYear,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createCohort(
        CreateCohortParams(
          name: event.name,
          entryYear: event.entryYear,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('cohort created. emit created notice');
          return CohortCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create cohort failed. emit failed notice');
          return CohortMutationFailedNotice(
            type: .create,
            exception: exception,
            cohort: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onCohortMutationUpdateRequested(
    CohortMutationUpdateRequested event,
    Emitter<CohortMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating cohort. emit updatingIds',
        extra: {
          'id': event.cohort.id,
          'name': event.name,
          'entryYear': event.entryYear,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.cohort.id},
        ),
      );

      final result = await _updateCohort(
        UpdateCohortParams(
          event.cohort,
          name: event.name,
          entryYear: event.entryYear,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('cohort updated. emit updated notice');
          return CohortUpdatedNotice(
            before: event.cohort,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update cohort failed. emit failed notice');
          return CohortMutationFailedNotice(
            type: .update,
            exception: exception,
            cohort: event.cohort,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.cohort.id),
        ),
      );
    });
  }

  Future<void> _onCohortMutationDeleteRequested(
    CohortMutationDeleteRequested event,
    Emitter<CohortMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting cohort. emit deletingIds',
        extra: {'id': event.cohort.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.cohort.id},
        ),
      );

      final result = await _deleteCohort(event.cohort);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('cohort deleted. emit deleted notice');
          return CohortDeletedNotice(event.cohort);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete cohort failed. emit failed notice');
          return CohortMutationFailedNotice(
            type: .delete,
            exception: exception,
            cohort: event.cohort,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.cohort.id),
        ),
      );
    });
  }
}
