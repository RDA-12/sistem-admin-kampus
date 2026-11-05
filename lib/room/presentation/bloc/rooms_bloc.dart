import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/models.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

/// Bloc for watching [Room] data changes
@injectable
class RoomsBloc extends Bloc<RoomsEvent, RoomsState> with AppLoggerMixin {
  /// Creates new [RoomsBloc]
  new({
    required this._watchRooms,
    required this._watchFaculties,
  }) : super(const RoomsInitial()) {
    on<RoomsSubscriptionRequested>(
      _onRoomsSubscriptionRequested,
      transformer: droppable(),
    );
  }

  final WatchRoomsUseCase _watchRooms;
  final WatchFacultiesUseCase _watchFaculties;

  Future<void> _onRoomsSubscriptionRequested(
    RoomsSubscriptionRequested event,
    Emitter<RoomsState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug('starts subscribe to rooms changes. emits loading');
      emit(const LoadingRooms());
      final stream = CombineLatestStream.combine2(
        _watchFaculties(null),
        _watchRooms(),
        (facultiesResult, roomsResult) {
          late final List<Faculty> faculties;
          switch (facultiesResult) {
            case AppFailure<List<Faculty>>(:final exception):
              return AppResult<List<RoomUI>>.failure(exception);
            case AppSuccess<List<Faculty>>(:final data):
              faculties = data;
          }
          switch (roomsResult) {
            case AppFailure<List<Room>>(:final exception):
              return AppResult<List<RoomUI>>.failure(exception);
            case AppSuccess<List<Room>>(:final data):
              final result = <RoomUI>[];
              for (final it in data) {
                final faculty = faculties.firstWhereOrNull(
                  (v) => v.id == it.facultyId,
                );
                if (faculty == null) continue;
                result.add(
                  RoomUI(
                    id: it.id,
                    facultyId: it.facultyId,
                    name: it.name,
                    faculty: faculty,
                  ),
                );
              }
              return AppResult.success(result);
          }
        },
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new rooms received. emit loaded');
              return RoomsLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return RoomsFailure(exception);
          }
        },
      );
    });
  }
}
