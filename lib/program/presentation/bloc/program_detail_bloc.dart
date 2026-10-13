import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/domain.dart';

part 'program_detail_event.dart';
part 'program_detail_state.dart';

/// Bloc for streaming a [Program] data changes
@Injectable(env: [Environment.prod])
class ProgramDetailBloc extends Bloc<ProgramDetailEvent, ProgramDetailState> {
  /// Creates new [ProgramDetailBloc]
  new({required this._watchSingleProgram})
    : super(const ProgramDetailInitial()) {
    on<ProgramDetailSubscriptionRequested>(
      _onProgramDetailSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleProgramUseCase _watchSingleProgram;

  Future<void> _onProgramDetailSubscriptionRequested(
    ProgramDetailSubscriptionRequested event,
    Emitter<ProgramDetailState> emit,
  ) async {
    emit(const LoadingProgramDetail());

    final stream = _watchSingleProgram(event.id);

    await emit.forEach(
      stream,
      onData: (result) {
        switch (result) {
          case AppSuccess(:final data):
            return ProgramDetailLoaded(program: data);
          case AppFailure(:final exception):
            return ProgramDetailLoadFailed(exception: exception);
        }
      },
    );
  }
}
