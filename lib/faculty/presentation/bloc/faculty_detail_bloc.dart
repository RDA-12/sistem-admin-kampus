import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

part 'faculty_detail_event.dart';
part 'faculty_detail_state.dart';

/// Bloc for streaming a [Faculty] data changes
@Injectable(env: [Environment.prod])
class FacultyDetailBloc extends Bloc<FacultyDetailEvent, FacultyDetailState>
    with AppLoggerMixin {
  /// Creates new [FacultyDetailBloc]
  new({required this._watchSingleFaculty})
    : super(const FacultyDetailInitial()) {
    on<FacultyDetailSubscriptionRequested>(
      _onFacultyDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleFacultyUseCase _watchSingleFaculty;

  Future<void> _onFacultyDetailSubscriptionRequested(
    FacultyDetailSubscriptionRequested event,
    Emitter<FacultyDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to faculty detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingFacultyDetail());

      final stream = _watchSingleFaculty(event.id);

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new faculty detail received. emit loaded');
              return FacultyDetailLoaded(faculty: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return FacultyDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
