import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/domain/entities.dart';
import 'package:sistem_admin/room/domain/repository.dart';

/// Params for creating a [Room]
final class CreateRoomParams extends Equatable {
  /// Creates new [CreateRoomParams]
  const new({
    required this.facultyId,
    required this.name,
  });

  /// ID of the parent faculty
  final String facultyId;

  /// Name for the room
  final String name;

  @override
  List<Object?> get props => [facultyId, name];
}

/// Use case for creating new [Room]
@LazySingleton(env: [Environment.prod])
class CreateRoomUseCase
    with AppLoggerMixin
    implements FutureBaseUseCase<CreateRoomParams, Room> {
  /// Creates new [CreateRoomUseCase]
  new({required this._roomRepository});

  final IRoomRepository _roomRepository;

  /// Run creating new [Room]
  @override
  Future<AppResult<Room>> call(CreateRoomParams params) async {
    logDebug(
      'start creating room',
      extra: {
        'facultyId': params.facultyId,
        'name': params.name,
      },
    );
    final result = await _roomRepository.save(params);
    switch (result) {
      case AppSuccess(:final data):
        logDebug('room created');
        return AppResult.success(data);
      case AppFailure<Room>(:final exception):
        logDebug('room creation failed');
        return AppResult.failure(exception);
    }
  }
}
