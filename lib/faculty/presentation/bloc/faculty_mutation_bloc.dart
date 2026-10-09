import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

part 'faculty_mutation_event.dart';
part 'faculty_mutation_state.dart';

/// Bloc for mutating [Faculty] data
@injectable
class FacultyMutationBloc
    extends Bloc<FacultyMutationEvent, FacultyMutationState> {
  /// Creates new [FacultyMutationBloc]
  new({
    required this._createFaculty,
    required this._updateFaculty,
    required this._deleteFaculty,
  }) : super(const FacultyMutationState()) {
    on<FacultyMutationCreateRequested>(
      _onFacultyMutationCreateRequested,
      transformer: sequential(),
    );
    on<FacultyMutationUpdateRequested>(
      _onFacultyMutationUpdateRequested,
    );
    on<FacultyMutationDeleteRequested>(
      _onFacultyMutationDeleteRequested,
    );
  }

  final CreateFacultyUseCase _createFaculty;
  final UpdateFacultyUseCase _updateFaculty;
  final DeleteFacultyUseCase _deleteFaculty;

  Future<void> _onFacultyMutationCreateRequested(
    FacultyMutationCreateRequested event,
    Emitter<FacultyMutationState> emit,
  ) async {
    emit(state.copyWith(isCreating: true));

    final result = await _createFaculty(
      CreateFacultyParams(name: event.name),
    );

    final notice = switch (result) {
      AppSuccess(:final data) => FacultyCreatedNotice(data),
      AppFailure(:final exception) => FacultyMutationFailedNotice(
        type: .create,
        exception: exception,
        faculty: null,
      ),
    };
    emit(state.copyWith(isCreating: false, notice: notice));
  }

  Future<void> _onFacultyMutationUpdateRequested(
    FacultyMutationUpdateRequested event,
    Emitter<FacultyMutationState> emit,
  ) async {
    emit(
      state.copyWith(
        updatingIds: {...state.updatingIds, event.faculty.id},
      ),
    );

    final result = await _updateFaculty(
      UpdateFacultyParams(event.faculty, name: event.name),
    );

    final notice = switch (result) {
      AppSuccess(:final data) => FacultyUpdatedNotice(
        before: event.faculty,
        after: data,
      ),
      AppFailure(:final exception) => FacultyMutationFailedNotice(
        type: .update,
        exception: exception,
        faculty: event.faculty,
      ),
    };
    emit(
      state.copyWith(
        notice: notice,
        updatingIds: {...state.updatingIds}..remove(event.faculty.id),
      ),
    );
  }

  Future<void> _onFacultyMutationDeleteRequested(
    FacultyMutationDeleteRequested event,
    Emitter<FacultyMutationState> emit,
  ) async {
    emit(state.copyWith(deletingIds: {...state.deletingIds, event.faculty.id}));

    final result = await _deleteFaculty(event.faculty);

    final notice = switch (result) {
      AppSuccess() => FacultyDeletedNotice(event.faculty),
      AppFailure(:final exception) => FacultyMutationFailedNotice(
        type: .delete,
        exception: exception,
        faculty: event.faculty,
      ),
    };
    emit(
      state.copyWith(
        notice: notice,
        deletingIds: {...state.deletingIds}..remove(event.faculty.id),
      ),
    );
  }
}
