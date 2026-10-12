import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

part 'faculties_event.dart';
part 'faculties_state.dart';

/// Bloc for watching [Faculty] data changes
@injectable
class FacultiesBloc extends Bloc<FacultiesEvent, FacultiesState> {
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
    emit(const LoadingFaculties());
    final stream = _watchFaculties(null);

    await emit.forEach(
      stream,
      onData: (result) {
        switch (result) {
          case AppSuccess(:final data):
            return FacultiesLoaded(data);
          case AppFailure(:final exception):
            return FacultiesFailure(exception);
        }
      },
    );
  }
}
