import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_year_mutation_event.dart';
part 'academic_year_mutation_state.dart';

/// Bloc for mutating [AcademicYear] data
@injectable
class AcademicYearMutationBloc
    extends Bloc<AcademicYearMutationEvent, AcademicYearMutationState>
    with AppLoggerMixin {
  /// Creates new [AcademicYearMutationBloc]
  new({
    required this._createAcademicYear,
    required this._updateAcademicYear,
    required this._deleteAcademicYear,
  }) : super(const AcademicYearMutationState()) {
    on<AcademicYearMutationCreateRequested>(
      _onAcademicYearMutationCreateRequested,
      transformer: sequential(),
    );
    on<AcademicYearMutationUpdateRequested>(
      _onAcademicYearMutationUpdateRequested,
    );
    on<AcademicYearMutationDeleteRequested>(
      _onAcademicYearMutationDeleteRequested,
    );
  }

  final CreateAcademicYearUseCase _createAcademicYear;
  final UpdateAcademicYearUseCase _updateAcademicYear;
  final DeleteAcademicYearUseCase _deleteAcademicYear;

  Future<void> _onAcademicYearMutationCreateRequested(
    AcademicYearMutationCreateRequested event,
    Emitter<AcademicYearMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating academic year. emit isCreating true',
        extra: {
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(state.copyWith(isCreating: true));

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
          return AcademicYearMutationFailedNotice(
            type: .create,
            exception: exception,
            academicYear: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onAcademicYearMutationUpdateRequested(
    AcademicYearMutationUpdateRequested event,
    Emitter<AcademicYearMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating academic year. emit updatingIds',
        extra: {
          'id': event.academicYear.id,
          'name': event.name,
          'startDate': event.startDate,
          'endDate': event.endDate,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.academicYear.id},
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
          return AcademicYearMutationFailedNotice(
            type: .update,
            exception: exception,
            academicYear: event.academicYear,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.academicYear.id),
        ),
      );
    });
  }

  Future<void> _onAcademicYearMutationDeleteRequested(
    AcademicYearMutationDeleteRequested event,
    Emitter<AcademicYearMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting academic year. emit deletingIds',
        extra: {'id': event.academicYear.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.academicYear.id},
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
          return AcademicYearMutationFailedNotice(
            type: .delete,
            exception: exception,
            academicYear: event.academicYear,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.academicYear.id),
        ),
      );
    });
  }
}
