import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'cohorts_event.dart';
part 'cohorts_state.dart';

/// Bloc for watching [Cohort] data changes
@injectable
class CohortsBloc extends Bloc<CohortsEvent, CohortsState> with AppLoggerMixin {
  /// Creates new [CohortsBloc]
  new({
    required this._watchCohorts,
  }) : super(const CohortsInitial()) {
    on<CohortsSubscriptionRequested>(
      _onCohortsSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchCohortsUseCase _watchCohorts;

  Future<void> _onCohortsSubscriptionRequested(
    CohortsSubscriptionRequested event,
    Emitter<CohortsState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to cohorts changes. emits loading');
      emit(const LoadingCohorts());
      final stream = _watchCohorts(null);

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new cohorts received. emit loaded');
              return CohortsLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return CohortsFailure(exception);
          }
        },
      );
    });
  }
}
