import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

part 'faculties_event.dart';
part 'faculties_state.dart';

/// Bloc for watching [Faculty] data changes
@injectable
class FacultiesBloc extends Bloc<FacultiesEvent, FacultiesState>
    with AppLoggerMixin {
  /// Creates new [FacultiesBloc]
  new({required this._watchFaculties}) : super(const FacultiesInitial()) {
    on<FacultiesSubscriptionRequested>(
      _onFacultiesSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchFacultiesUseCase _watchFaculties;

  Future<void> _onFacultiesSubscriptionRequested(
    FacultiesSubscriptionRequested event,
    Emitter<FacultiesState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to faculties changes. emits loading');
      emit(const LoadingFaculties());
      final stream = _watchFaculties(null);

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new faculties received. emit loaded');
              return FacultiesLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return FacultiesFailure(exception);
          }
        },
      );
    });
  }
}
