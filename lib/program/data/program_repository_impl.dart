import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/data/data.dart';
import 'package:sistem_admin/program/domain/domain.dart';

/// Implementation of [IProgramRepository]
@LazySingleton(as: IProgramRepository, env: [Environment.prod])
class ProgramRepository with AppLoggerMixin implements IProgramRepository {
  /// Creates new [ProgramRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete program query', extra: {'id': id});
      final query = _db.delete(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting program');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Program>> save(CreateProgramParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing program name query',
        extra: {'name': args.name, 'facultyId': args.facultyId},
      );
      final query = _db.select(_db.programsDrift)
        ..where(
          (tbl) =>
              tbl.facultyId.equals(args.facultyId) & tbl.name.equals(args.name),
        );
      logDebug('start getting existing program name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('program name exists');
        return AppResult.failure(
          AppException(
            'program with name ${args.name} already exists in '
            'faculty ${args.facultyId}',
            code: .programAlreadyExists,
          ),
        );
      }
      logDebug('program name not exists. start insert program query');
      final id = _uidGenerator.generate();
      final programInsert = ProgramsDriftCompanion.insert(
        id: id,
        facultyId: args.facultyId,
        name: args.name,
      );
      logDebug('start inserting program');
      final programDb = await _db
          .into(_db.programsDrift)
          .insertReturning(programInsert);
      logDebug('program inserted');
      return AppResult.success(programDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Program>> update(
    String id, {
    required UpdateProgramParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check program query', extra: {'id': id});
      final query = _db.select(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking program');
      final programDb = await query.getSingleOrNull();
      if (programDb == null) {
        logDebug('program not found');
        return AppResult.failure(
          AppException('program with id $id not found', code: .programNotFound),
        );
      }
      logDebug('program found');
      if (args.name != null) {
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name, 'facultyId': programDb.facultyId},
        );
        final existingNameQuery = _db.select(_db.programsDrift)
          ..where(
            (tbl) =>
                tbl.name.equals(args.name!) &
                tbl.facultyId.equals(programDb.facultyId),
          );
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null) {
          logDebug('program name already exists');
          return AppResult.failure(
            AppException(
              'program with name ${args.name} '
              'within same faculty already exists',
              code: .programAlreadyExists,
            ),
          );
        }
      }
      logDebug('program name not found. construct update query');
      final updateQuery = _db.update(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating program');
      final programsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedProgramDb = programsDb.first;
      logDebug('program updated');
      return AppResult.success(updatedProgramDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Program>>> watch([ProgramFilter? filter]) {
    logDebug('construct select programs query', extra: {'filter': filter});
    var query = _db.select(_db.programsDrift);
    if (filter != null) {
      query = filter.apply(query);
    }
    logDebug('start watching programs');
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
  Stream<AppResult<Program>> watchSingle(String id) async* {
    logDebug('construct select query for single program', extra: {'id': id});
    final query = _db.select(_db.programsDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking program exist or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('program not found');
      yield AppResult.failure(
        AppException('program with ID $id not found', code: .programNotFound),
      );
    }
    logDebug('program found. start watching program');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
