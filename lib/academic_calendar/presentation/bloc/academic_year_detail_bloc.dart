import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_year_detail_event.dart';
part 'academic_year_detail_state.dart';

/// Bloc for streaming an [AcademicYear] data changes
@injectable
class AcademicYearDetailBloc
    extends Bloc<AcademicYearDetailEvent, AcademicYearDetailState>
    with AppLoggerMixin {
  /// Creates new [AcademicYearDetailBloc]
  new({
    required this._watchSingleAcademicYear,
    required this._watchAcademicTermsByYear,
  }) : super(const AcademicYearDetailInitial()) {
    on<AcademicYearDetailSubscriptionRequested>(
      _onAcademicYearDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleAcademicYearUseCase _watchSingleAcademicYear;
  final WatchAcademicTermsByYearUseCase _watchAcademicTermsByYear;

  Future<void> _onAcademicYearDetailSubscriptionRequested(
    AcademicYearDetailSubscriptionRequested event,
    Emitter<AcademicYearDetailState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to academic year detail changes. emits loading',
        extra: {'id': event.id},
      );
      emit(const LoadingAcademicYearDetail());

      final stream = CombineLatestStream.combine2(
        _watchSingleAcademicYear(event.id),
        _watchAcademicTermsByYear(event.id),
        (yearResult, termsResult) {
          late final AcademicYear academicYear;
          switch (yearResult) {
            case AppFailure<AcademicYear>(:final exception):
              return AppResult<AcademicYearDetailLoaded>.failure(exception);
            case AppSuccess<AcademicYear>(:final data):
              academicYear = data;
          }
          switch (termsResult) {
            case AppFailure<List<AcademicTerm>>(:final exception):
              return AppResult<AcademicYearDetailLoaded>.failure(exception);
            case AppSuccess<List<AcademicTerm>>(:final data):
              return AppResult.success(
                AcademicYearDetailLoaded(
                  academicYear: academicYear,
                  terms: data,
                ),
              );
          }
        },
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new academic year detail received. emit loaded');
              return data;
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return AcademicYearDetailLoadFailed(exception: exception);
          }
        },
      );
    });
  }
}
