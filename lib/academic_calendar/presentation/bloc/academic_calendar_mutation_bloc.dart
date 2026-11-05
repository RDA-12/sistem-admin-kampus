import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_calendar_mutation_event.dart';
part 'academic_calendar_mutation_state.dart';

/// Bloc for mutating Academic Calendar ([AcademicYear], [AcademicTerm],
/// and [AcademicCalendarEvent]) data
@injectable
class AcademicCalendarMutationBloc
    extends Bloc<AcademicCalendarMutationEvent, AcademicCalendarMutationState>
    with AppLoggerMixin {
  /// Creates new [AcademicCalendarMutationBloc]
  new({
    required this._createAcademicYear,
    required this._updateAcademicYear,
    required this._deleteAcademicYear,
    required this._createAcademicTerm,
    required this._updateAcademicTerm,
    required this._deleteAcademicTerm,
    required this._createAcademicCalendarEvent,
    required this._updateAcademicCalendarEvent,
    required this._deleteAcademicCalendarEvent,
  }) : super(const AcademicCalendarMutationState()) {
    on<AcademicCalendarYearCreateRequested>(
      _onAcademicCalendarYearCreateRequested,
      transformer: sequential(),
    );
    on<AcademicCalendarYearUpdateRequested>(
      _onAcademicCalendarYearUpdateRequested,
    );
    on<AcademicCalendarYearDeleteRequested>(
      _onAcademicCalendarYearDeleteRequested,
    );
    on<AcademicCalendarTermCreateRequested>(
      _onAcademicCalendarTermCreateRequested,
      transformer: sequential(),
    );
    on<AcademicCalendarTermUpdateRequested>(
      _onAcademicCalendarTermUpdateRequested,
    );
    on<AcademicCalendarTermDeleteRequested>(
      _onAcademicCalendarTermDeleteRequested,
    );
    on<AcademicCalendarEventCreateRequested>(
      _onAcademicCalendarEventCreateRequested,
      transformer: sequential(),
    );
    on<AcademicCalendarEventUpdateRequested>(
      _onAcademicCalendarEventUpdateRequested,
    );
    on<AcademicCalendarEventDeleteRequested>(
      _onAcademicCalendarEventDeleteRequested,
    );
  }

  final CreateAcademicYearUseCase _createAcademicYear;
  final UpdateAcademicYearUseCase _updateAcademicYear;
  final DeleteAcademicYearUseCase _deleteAcademicYear;
  final CreateAcademicTermUseCase _createAcademicTerm;
  final UpdateAcademicTermUseCase _updateAcademicTerm;
  final DeleteAcademicTermUseCase _deleteAcademicTerm;
  final CreateAcademicCalendarEventUseCase _createAcademicCalendarEvent;
  final UpdateAcademicCalendarEventUseCase _updateAcademicCalendarEvent;
  final DeleteAcademicCalendarEventUseCase _deleteAcademicCalendarEvent;

  Future<void> _onAcademicCalendarYearCreateRequested(
    AcademicCalendarYearCreateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating academic year. emit isCreatingYear true',
        extra: {
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(state.copyWith(isCreatingYear: true));

      final result = await _createAcademicYear(
        CreateAcademicYearParams(
          name: event.name,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic year created. emit created notice');
          return AcademicYearCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create academic year failed. emit failed notice');
          return AcademicCalendarMutationFailedNotice(
            type: .create,
            target: .year,
            exception: exception,
          );
        }(),
      };
      emit(state.copyWith(isCreatingYear: false, notice: notice));
    });
  }

  Future<void> _onAcademicCalendarYearUpdateRequested(
    AcademicCalendarYearUpdateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating academic year. emit updatingYearIds',
        extra: {
          'id': event.academicYear.id,
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(
        state.copyWith(
          updatingYearIds: {...state.updatingYearIds, event.academicYear.id},
        ),
      );

      final result = await _updateAcademicYear(
        UpdateAcademicYearParams(
          event.academicYear,
          name: event.name,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic year updated. emit updated notice');
          return AcademicYearUpdatedNotice(
            before: event.academicYear,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update academic year failed. emit failed notice');
          return AcademicCalendarMutationFailedNotice(
            type: .update,
            target: .year,
            exception: exception,
            academicYear: event.academicYear,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingYearIds: {...state.updatingYearIds}
            ..remove(event.academicYear.id),
        ),
      );
    });
  }

  Future<void> _onAcademicCalendarYearDeleteRequested(
    AcademicCalendarYearDeleteRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting academic year. emit deletingYearIds',
        extra: {'id': event.academicYear.id},
      );
      emit(
        state.copyWith(
          deletingYearIds: {...state.deletingYearIds, event.academicYear.id},
        ),
      );

      final result = await _deleteAcademicYear(event.academicYear);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('academic year deleted. emit deleted notice');
          return AcademicYearDeletedNotice(event.academicYear);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete academic year failed. emit failed notice');
          return AcademicCalendarMutationFailedNotice(
            type: .delete,
            target: .year,
            exception: exception,
            academicYear: event.academicYear,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingYearIds: {...state.deletingYearIds}
            ..remove(event.academicYear.id),
        ),
      );
    });
  }

  Future<void> _onAcademicCalendarTermCreateRequested(
    AcademicCalendarTermCreateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating academic term. emit isCreatingTerm true',
        extra: {
          'academicYearId': event.academicYearId,
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(state.copyWith(isCreatingTerm: true));

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
          return AcademicCalendarMutationFailedNotice(
            type: .create,
            target: .term,
            exception: exception,
          );
        }(),
      };
      emit(state.copyWith(isCreatingTerm: false, notice: notice));
    });
  }

  Future<void> _onAcademicCalendarTermUpdateRequested(
    AcademicCalendarTermUpdateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating academic term. emit updatingTermIds',
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
          updatingTermIds: {...state.updatingTermIds, event.academicTerm.id},
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
          return AcademicCalendarMutationFailedNotice(
            type: .update,
            target: .term,
            exception: exception,
            academicTerm: event.academicTerm,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingTermIds: {...state.updatingTermIds}
            ..remove(event.academicTerm.id),
        ),
      );
    });
  }

  Future<void> _onAcademicCalendarTermDeleteRequested(
    AcademicCalendarTermDeleteRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting academic term. emit deletingTermIds',
        extra: {'id': event.academicTerm.id},
      );
      emit(
        state.copyWith(
          deletingTermIds: {...state.deletingTermIds, event.academicTerm.id},
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
          return AcademicCalendarMutationFailedNotice(
            type: .delete,
            target: .term,
            exception: exception,
            academicTerm: event.academicTerm,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingTermIds: {...state.deletingTermIds}
            ..remove(event.academicTerm.id),
        ),
      );
    });
  }

  Future<void> _onAcademicCalendarEventCreateRequested(
    AcademicCalendarEventCreateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating academic calendar event. emit isCreatingEvent true',
        extra: {
          'academicYearId': event.academicYearId,
          'name': event.name,
          'type': event.type,
          'start': event.start,
          'end': event.end,
          'recurrence': event.recurrence,
        },
      );
      emit(state.copyWith(isCreatingEvent: true));

      final result = await _createAcademicCalendarEvent(
        CreateAcademicCalendarEventParams(
          academicYearId: event.academicYearId,
          name: event.name,
          type: event.type,
          start: event.start,
          end: event.end,
          recurrence: event.recurrence,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic calendar event created. emit created notice');
          return AcademicCalendarEventCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug(
            'create academic calendar event failed. emit failed notice',
          );
          return AcademicCalendarMutationFailedNotice(
            type: .create,
            target: .event,
            exception: exception,
          );
        }(),
      };
      emit(state.copyWith(isCreatingEvent: false, notice: notice));
    });
  }

  Future<void> _onAcademicCalendarEventUpdateRequested(
    AcademicCalendarEventUpdateRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating academic calendar event. emit updatingEventIds',
        extra: {
          'id': event.event.id,
          'academicYearId': event.academicYearId,
          'name': event.name,
          'type': event.type,
          'start': event.start,
          'end': event.end,
          'recurrence': event.recurrence,
        },
      );
      emit(
        state.copyWith(
          updatingEventIds: {...state.updatingEventIds, event.event.id},
        ),
      );

      final result = await _updateAcademicCalendarEvent(
        UpdateAcademicCalendarEventParams(
          event.event,
          academicYearId: event.academicYearId,
          name: event.name,
          type: event.type,
          start: event.start,
          end: event.end,
          recurrence: event.recurrence,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('academic calendar event updated. emit updated notice');
          return AcademicCalendarEventUpdatedNotice(
            before: event.event,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug(
            'update academic calendar event failed. emit failed notice',
          );
          return AcademicCalendarMutationFailedNotice(
            type: .update,
            target: .event,
            exception: exception,
            academicCalendarEvent: event.event,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingEventIds: {...state.updatingEventIds}..remove(event.event.id),
        ),
      );
    });
  }

  Future<void> _onAcademicCalendarEventDeleteRequested(
    AcademicCalendarEventDeleteRequested event,
    Emitter<AcademicCalendarMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting academic calendar event. emit deletingEventIds',
        extra: {'id': event.event.id},
      );
      emit(
        state.copyWith(
          deletingEventIds: {...state.deletingEventIds, event.event.id},
        ),
      );

      final result = await _deleteAcademicCalendarEvent(event.event);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('academic calendar event deleted. emit deleted notice');
          return AcademicCalendarEventDeletedNotice(event.event);
        }(),
        AppFailure(:final exception) => () {
          logDebug(
            'delete academic calendar event failed. emit failed notice',
          );
          return AcademicCalendarMutationFailedNotice(
            type: .delete,
            target: .event,
            exception: exception,
            academicCalendarEvent: event.event,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingEventIds: {...state.deletingEventIds}..remove(event.event.id),
        ),
      );
    });
  }
}
