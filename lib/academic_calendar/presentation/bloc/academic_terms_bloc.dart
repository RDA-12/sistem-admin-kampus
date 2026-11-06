import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

part 'academic_terms_event.dart';
part 'academic_terms_state.dart';

/// Bloc for watching [AcademicTerm] data changes
@injectable
class AcademicTermsBloc extends Bloc<AcademicTermsEvent, AcademicTermsState>
    with AppLoggerMixin {
  /// Creates new [AcademicTermsBloc]
  new({
    required this._watchAcademicTerms,
  }) : super(const AcademicTermsInitial()) {
    on<AcademicTermsSubscriptionRequested>(
      _onAcademicTermsSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchAcademicTermsUseCase _watchAcademicTerms;

  Future<void> _onAcademicTermsSubscriptionRequested(
    AcademicTermsSubscriptionRequested event,
    Emitter<AcademicTermsState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to academic terms changes. emits loading',
        extra: event.academicYearId != null
            ? {'academicYearId': event.academicYearId}
            : null,
      );
      emit(const LoadingAcademicTerms());
      final stream = _watchAcademicTerms(
        AcademicTermFilter(academicYearId: event.academicYearId),
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new academic terms received. emit loaded');
              return AcademicTermsLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return AcademicTermsFailure(exception);
          }
        },
      );
    });
  }
}
