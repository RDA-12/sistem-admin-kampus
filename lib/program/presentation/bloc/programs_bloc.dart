import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/domain/domain.dart';

part 'programs_event.dart';
part 'programs_state.dart';

/// Bloc for watching [Program] data changes
@injectable
class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  /// Creates new [ProgramsBloc]
  new({required this._watchPrograms}) : super(const ProgramsInitial()) {
    on<ProgramsSubscriptionRequested>(
      _onProgramsSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchProgramsUseCase _watchPrograms;

  Future<void> _onProgramsSubscriptionRequested(
    ProgramsSubscriptionRequested event,
    Emitter<ProgramsState> emit,
  ) async {
    emit(const LoadingPrograms());
    final stream = _watchPrograms(null);

    await emit.forEach(
      stream,
      onData: (result) {
        switch (result) {
          case AppSuccess(:final data):
            return ProgramsLoaded(data);
          case AppFailure(:final exception):
            return ProgramsFailure(exception);
        }
      },
    );
  }
}
