import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';

part 'lecturer_mutation_event.dart';
part 'lecturer_mutation_state.dart';

/// Bloc for mutating [Lecturer] data
@injectable
class LecturerMutationBloc
    extends Bloc<LecturerMutationEvent, LecturerMutationState>
    with AppLoggerMixin {
  /// Creates new [LecturerMutationBloc]
  new({
    required this._createLecturer,
    required this._updateLecturer,
    required this._deleteLecturer,
  }) : super(const LecturerMutationState()) {
    on<LecturerMutationCreateRequested>(
      _onLecturerMutationCreateRequested,
      transformer: sequential(),
    );
    on<LecturerMutationUpdateRequested>(
      _onLecturerMutationUpdateRequested,
    );
    on<LecturerMutationDeleteRequested>(
      _onLecturerMutationDeleteRequested,
    );
  }

  final CreateLecturerUseCase _createLecturer;
  final UpdateLecturerUseCase _updateLecturer;
  final DeleteLecturerUseCase _deleteLecturer;

  Future<void> _onLecturerMutationCreateRequested(
    LecturerMutationCreateRequested event,
    Emitter<LecturerMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start creating lecturer. emit isCreating true',
        extra: {
          'programId': event.programId,
          'name': event.name,
          'pangkatGolongan': event.pangkatGolongan,
        },
      );
      emit(state.copyWith(isCreating: true));

      final result = await _createLecturer(
        CreateLecturerParams(
          programId: event.programId,
          name: event.name,
          pangkatGolongan: event.pangkatGolongan,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('lecturer created. emit created notice');
          return LecturerCreatedNotice(data);
        }(),
        AppFailure(:final exception) => () {
          logDebug('create lecturer failed. emit failure notice');
          return LecturerMutationFailedNotice(
            type: LecturerMutationType.create,
            exception: exception,
            lecturer: null,
          );
        }(),
      };
      emit(state.copyWith(isCreating: false, notice: notice));
    });
  }

  Future<void> _onLecturerMutationUpdateRequested(
    LecturerMutationUpdateRequested event,
    Emitter<LecturerMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start updating lecturer. emit updatingIds',
        extra: {
          'id': event.lecturer.id,
          'name': event.name,
          'pangkatGolongan': event.pangkatGolongan,
          'programId': event.programId,
        },
      );
      emit(
        state.copyWith(
          updatingIds: {...state.updatingIds, event.lecturer.id},
        ),
      );

      final result = await _updateLecturer(
        UpdateLecturerParams(
          event.lecturer,
          name: event.name,
          pangkatGolongan: event.pangkatGolongan,
          programId: event.programId,
        ),
      );

      final notice = switch (result) {
        AppSuccess(:final data) => () {
          logDebug('lecturer updated. emit updated notice');
          return LecturerUpdatedNotice(
            before: event.lecturer,
            after: data,
          );
        }(),
        AppFailure(:final exception) => () {
          logDebug('update lecturer failed. emit failure notice');
          return LecturerMutationFailedNotice(
            type: LecturerMutationType.update,
            exception: exception,
            lecturer: event.lecturer,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          updatingIds: {...state.updatingIds}..remove(event.lecturer.id),
        ),
      );
    });
  }

  Future<void> _onLecturerMutationDeleteRequested(
    LecturerMutationDeleteRequested event,
    Emitter<LecturerMutationState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'start deleting lecturer. emit deletingIds',
        extra: {'id': event.lecturer.id},
      );
      emit(
        state.copyWith(
          deletingIds: {...state.deletingIds, event.lecturer.id},
        ),
      );

      final result = await _deleteLecturer(event.lecturer);

      final notice = switch (result) {
        AppSuccess() => () {
          logDebug('lecturer deleted. emit deleted notice');
          return LecturerDeletedNotice(event.lecturer);
        }(),
        AppFailure(:final exception) => () {
          logDebug('delete lecturer failed. emit failure notice');
          return LecturerMutationFailedNotice(
            type: LecturerMutationType.delete,
            exception: exception,
            lecturer: event.lecturer,
          );
        }(),
      };
      emit(
        state.copyWith(
          notice: notice,
          deletingIds: {...state.deletingIds}..remove(event.lecturer.id),
        ),
      );
    });
  }
}
