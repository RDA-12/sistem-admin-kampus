import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'cohort_detail_event.dart';
part 'cohort_detail_state.dart';

/// Bloc for streaming a [Cohort] data changes
@injectable
class CohortDetailBloc extends Bloc<CohortDetailEvent, CohortDetailState>
    with AppLoggerMixin {
  /// Creates new [CohortDetailBloc]
  new({
    required this._watchSingleCohort,
  }) : super(const CohortDetailInitial()) {
    on<CohortDetailSubscriptionRequested>(
      _onCohortDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleCohortUseCase _watchSingleCohort;

  Future<void> _onCohortDetailSubscriptionRequested(
    CohortDetailSubscriptionRequested event,
    Emitter<CohortDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to cohort detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingCohortDetail());

      final stream = _watchSingleCohort(event.id);

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new cohort detail received. emit loaded');
              return CohortDetailLoaded(cohort: data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return CohortDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
