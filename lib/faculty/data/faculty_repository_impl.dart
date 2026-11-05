import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/data/data.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';

/// Implementation of [IFacultyRepository]
@LazySingleton(as: IFacultyRepository, env: [Environment.prod])
class FacultyRepository with AppLoggerMixin implements IFacultyRepository {
  /// Creates new [FacultyRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete faculty query', extra: {'id': id});
      final query = _db.delete(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting faculty');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Faculty>> save(CreateFacultyParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing faculty name query',
        extra: {'name': args.name},
      );
      final query = _db.select(_db.facultiesDrift)
        ..where((tbl) => tbl.name.equals(args.name));
      logDebug('start getting existing faculty name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('faculty name exists');
        return AppResult.failure(
          AppException(
            'faculty with name ${args.name} already exists',
            code: .facultyAlreadyExists,
          ),
        );
      }
      logDebug('faculty name not exists. start insert faculty query');
      final id = _uidGenerator.generate();
      final facultyInsert = FacultiesDriftCompanion.insert(
        id: id,
        name: args.name,
      );
      logDebug('start inserting faculty');
      final facultyDb = await _db
          .into(_db.facultiesDrift)
          .insertReturning(facultyInsert);
      logDebug('faculty inserted');
      return AppResult.success(facultyDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Faculty>> update(
    String id, {
    required UpdateFacultyParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check faculty query', extra: {'id': id});
      final query = _db.select(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking faculty');
      final facultyDb = await query.getSingleOrNull();
      if (facultyDb == null) {
        logDebug('faculty not found');
        return AppResult.failure(
          AppException('faculty with id $id not found', code: .facultyNotFound),
        );
      }
      logDebug('faculty found');
      if (args.name != null) {
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name},
        );
        final nameExistingQuery = _db.select(_db.facultiesDrift)
          ..where((tbl) => tbl.name.equals(args.name!));
        logDebug('start checking existing name');
        final nameExists = await nameExistingQuery.getSingleOrNull();
        if (nameExists != null) {
          logDebug('faculty name already exists');
          return AppResult.failure(
            AppException(
              'faculty with name ${args.name} already exists',
              code: .facultyAlreadyExists,
            ),
          );
        }
      }
      logDebug('faculty name not found. construct update query');
      final updateQuery = _db.update(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating faculty');
      final facultiesDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedFacultyDb = facultiesDb.first;
      logDebug('faculty updated');
      return AppResult.success(updatedFacultyDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Faculty>>> watch([NoFilter? filter]) {
    logDebug('construct select faculties query');
    final query = _db.select(_db.facultiesDrift);
    logDebug('start watching faculties');
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
  Stream<AppResult<Faculty>> watchSingle(String id) async* {
    logDebug('construct select query for single faculty', extra: {'id': id});
    final query = _db.select(_db.facultiesDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking faculty exist or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('faculty not found');
      yield AppResult.failure(
        AppException('faculty with ID $id not found', code: .facultyNotFound),
      );
    }
    logDebug('faculty found. start watching faculty');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
