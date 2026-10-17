import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_years_event.dart';
part 'academic_years_state.dart';

/// Bloc for watching [AcademicYear] data changes
@injectable
class AcademicYearsBloc extends Bloc<AcademicYearsEvent, AcademicYearsState>
    with AppLoggerMixin {
  /// Creates new [AcademicYearsBloc]
  new({
    required this._watchAcademicYears,
  }) : super(const AcademicYearsInitial()) {
    on<AcademicYearsSubscriptionRequested>(
      _onAcademicYearsSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchAcademicYearsUseCase _watchAcademicYears;

  Future<void> _onAcademicYearsSubscriptionRequested(
    AcademicYearsSubscriptionRequested event,
    Emitter<AcademicYearsState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to academic years changes. emits loading');
      emit(const LoadingAcademicYears());
      final stream = _watchAcademicYears(null);

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new academic years received. emit loaded');
              return AcademicYearsLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return AcademicYearsFailure(exception);
          }
        },
      );
    });
  }
}
