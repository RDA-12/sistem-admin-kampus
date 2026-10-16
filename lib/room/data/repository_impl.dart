import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/room/data/data.dart';
import 'package:sistem_admin/room/domain/domain.dart';

/// Implementation of [IRoomRepository]
@LazySingleton(as: IRoomRepository, env: [Environment.prod])
class RoomRepository with AppLoggerMixin implements IRoomRepository {
  /// Creates new [RoomRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete room query', extra: {'id': id});
      final query = _db.delete(_db.roomsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting room');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Room>> save(CreateRoomParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing room name query',
        extra: {'name': args.name, 'facultyId': args.facultyId},
      );
      final query = _db.select(_db.roomsDrift)
        ..where(
          (tbl) =>
              tbl.facultyId.equals(args.facultyId) & tbl.name.equals(args.name),
        );
      logDebug('start getting existing room name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('room name exists');
        return AppResult.failure(
          AppException(
            'room with name ${args.name} already exists in '
            'faculty ${args.facultyId}',
            code: .roomAlreadyExists,
          ),
        );
      }
      logDebug('room name not exists. start insert room query');
      final id = _uidGenerator.generate();
      final roomInsert = RoomsDriftCompanion.insert(
        id: id,
        facultyId: args.facultyId,
        name: args.name,
      );
      logDebug('start inserting room');
      final roomDb = await _db.into(_db.roomsDrift).insertReturning(roomInsert);
      logDebug('room inserted');
      return AppResult.success(roomDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Room>> update(
    String id, {
    required UpdateRoomParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check room query', extra: {'id': id});
      final query = _db.select(_db.roomsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking room');
      final roomDb = await query.getSingleOrNull();
      if (roomDb == null) {
        logDebug('room not found');
        return AppResult.failure(
          AppException('room with id $id not found', code: .roomNotFound),
        );
      }
      logDebug('room found');
      if (args.name != null) {
        final targetFacultyId = args.facultyId ?? roomDb.facultyId;
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name, 'facultyId': targetFacultyId},
        );
        final existingNameQuery = _db.select(_db.roomsDrift)
          ..where(
            (tbl) =>
                tbl.name.equals(args.name!) &
                tbl.facultyId.equals(targetFacultyId),
          );
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null) {
          logDebug('room name already exists');
          return AppResult.failure(
            AppException(
              'room with name ${args.name} '
              'within same faculty already exists',
              code: .roomAlreadyExists,
            ),
          );
        }
      }
      logDebug('room name not found. construct update query');
      final updateQuery = _db.update(_db.roomsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating room');
      final roomsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedRoomDb = roomsDb.first;
      logDebug('room updated');
      return AppResult.success(updatedRoomDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Room>>> watch() {
    logDebug('construct select rooms query');
    final query = _db.select(_db.roomsDrift);
    logDebug('start watching rooms');
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(this, Invocation.method(#watch, null));
            return AppResult.success(it.map((v) => v.toDomain()).toList());
          },
        )
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(
            AppException('$error', code: .internal),
          );
        });
  }

  @override
  Stream<AppResult<List<Room>>> watchByFaculty(String facultyId) {
    logDebug(
      'construct select rooms by faculty query',
      extra: {'facultyId': facultyId},
    );
    final query = _db.select(_db.roomsDrift)
      ..where((tbl) => tbl.facultyId.equals(facultyId));
    logDebug('start watching rooms by faculty');
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(
              this,
              Invocation.method(#watchByFaculty, [facultyId]),
            );
            return AppResult.success(it.map((v) => v.toDomain()).toList());
          },
        )
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(
            AppException('$error', code: .internal),
          );
        });
  }

  @override
  Stream<AppResult<Room>> watchSingle(String id) async* {
    logDebug('construct select query for single room', extra: {'id': id});
    final query = _db.select(_db.roomsDrift)..where((tbl) => tbl.id.equals(id));
    logDebug('start checking room exist or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('room not found');
      yield AppResult.failure(
        AppException('room with ID $id not found', code: .roomNotFound),
      );
    }
    logDebug('room found. start watching room');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
