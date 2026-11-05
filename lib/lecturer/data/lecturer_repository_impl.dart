import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/data/data.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';

/// Implementation of [ILecturerRepository]
@LazySingleton(as: ILecturerRepository, env: [Environment.prod])
class LecturerRepository with AppLoggerMixin implements ILecturerRepository {
  /// Creates new [LecturerRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete lecturer query', extra: {'id': id});
      final query = _db.delete(_db.lecturersDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting lecturer');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Lecturer>> save(CreateLecturerParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing lecturer name query',
        extra: {'name': args.name, 'programId': args.programId},
      );
      final query = _db.select(_db.lecturersDrift)
        ..where(
          (tbl) =>
              tbl.programId.equals(args.programId) & tbl.name.equals(args.name),
        );
      logDebug('start getting existing lecturer name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('lecturer name exists');
        return AppResult.failure(
          AppException(
            'lecturer with name ${args.name} already exists in '
            'program ${args.programId}',
            code: .lecturerAlreadyExists,
          ),
        );
      }
      logDebug('lecturer name not exists. start insert lecturer query');
      final id = _uidGenerator.generate();
      final lecturerInsert = LecturersDriftCompanion.insert(
        id: id,
        programId: args.programId,
        name: args.name,
        pangkatGolongan: args.pangkatGolongan,
      );
      logDebug('start inserting lecturer');
      final lecturerDb = await _db
          .into(_db.lecturersDrift)
          .insertReturning(lecturerInsert);
      logDebug('lecturer inserted');
      return AppResult.success(lecturerDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Lecturer>> update(
    String id, {
    required UpdateLecturerParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check lecturer query', extra: {'id': id});
      final query = _db.select(_db.lecturersDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking lecturer');
      final lecturerDb = await query.getSingleOrNull();
      if (lecturerDb == null) {
        logDebug('lecturer not found');
        return AppResult.failure(
          AppException(
            'lecturer with id $id not found',
            code: .lecturerNotFound,
          ),
        );
      }
      logDebug('lecturer found');
      final targetProgramId = args.programId ?? lecturerDb.programId;
      if (args.name != null) {
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name, 'programId': targetProgramId},
        );
        final existingNameQuery = _db.select(_db.lecturersDrift)
          ..where(
            (tbl) =>
                tbl.name.equals(args.name!) &
                tbl.programId.equals(targetProgramId),
          );
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null && nameExists.id != id) {
          logDebug('lecturer name already exists');
          return AppResult.failure(
            AppException(
              'lecturer with name ${args.name} '
              'within same program already exists',
              code: .lecturerAlreadyExists,
            ),
          );
        }
      }
      logDebug('lecturer name not found. construct update query');
      final updateQuery = _db.update(_db.lecturersDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating lecturer');
      final lecturersDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedLecturerDb = lecturersDb.first;
      logDebug('lecturer updated');
      return AppResult.success(updatedLecturerDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Lecturer>>> watch([LecturerFilter? filter]) {
    logDebug('construct select lecturers query', extra: {'filter': filter});
    var query = _db.select(_db.lecturersDrift);
    if (filter != null) {
      query = filter.apply(query);
    }
    logDebug('start watching lecturers');
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(this, Invocation.method(#watch, [filter]));
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
  Stream<AppResult<Lecturer>> watchSingle(String id) async* {
    logDebug('construct select query for single lecturer', extra: {'id': id});
    final query = _db.select(_db.lecturersDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking lecturer exist or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('lecturer not found');
      yield AppResult.failure(
        AppException('lecturer with ID $id not found', code: .lecturerNotFound),
      );
    }
    logDebug('lecturer found. start watching lecturer');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
