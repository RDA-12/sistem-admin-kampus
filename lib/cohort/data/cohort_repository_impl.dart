import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/cohort/data/data.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Implementation of [ICohortRepository]
@LazySingleton(as: ICohortRepository, env: [Environment.prod])
class CohortRepository with AppLoggerMixin implements ICohortRepository {
  /// Creates new [CohortRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete cohort query', extra: {'id': id});
      final query = _db.delete(_db.cohortsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting cohort');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Cohort>> save(CreateCohortParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing cohort name query',
        extra: {'name': args.name},
      );
      final query = _db.select(_db.cohortsDrift)
        ..where((tbl) => tbl.name.equals(args.name));
      logDebug('start getting existing cohort name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('cohort name exists');
        return AppResult.failure(
          AppException(
            'cohort with name ${args.name} already exists',
            code: .cohortAlreadyExists,
          ),
        );
      }
      logDebug('cohort name not exists. start insert query');
      final id = _uidGenerator.generate();
      final cohortInsert = CohortsDriftCompanion.insert(
        id: id,
        name: args.name,
        entryYear: args.entryYear,
      );
      logDebug('start inserting cohort');
      final cohortDb = await _db
          .into(_db.cohortsDrift)
          .insertReturning(cohortInsert);
      logDebug('cohort inserted');
      return AppResult.success(cohortDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Cohort>> update(
    String id, {
    required UpdateCohortParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check cohort query', extra: {'id': id});
      final query = _db.select(_db.cohortsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking cohort');
      final cohortDb = await query.getSingleOrNull();
      if (cohortDb == null) {
        logDebug('cohort not found');
        return AppResult.failure(
          AppException(
            'cohort with id $id not found',
            code: .cohortNotFound,
          ),
        );
      }
      logDebug('cohort found');
      if (args.name != null && args.name != cohortDb.name) {
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name},
        );
        final existingNameQuery = _db.select(_db.cohortsDrift)
          ..where((tbl) => tbl.name.equals(args.name!));
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null) {
          logDebug('cohort name already exists');
          return AppResult.failure(
            AppException(
              'cohort with name ${args.name} already exists',
              code: .cohortAlreadyExists,
            ),
          );
        }
      }
      logDebug('name check passed. construct update query');
      final updateQuery = _db.update(_db.cohortsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating cohort');
      final cohortsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedCohortDb = cohortsDb.first;
      logDebug('cohort updated');
      return AppResult.success(updatedCohortDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Cohort>>> watch() {
    logDebug('construct select cohorts query');
    final query = _db.select(_db.cohortsDrift);
    logDebug('start watching cohorts');
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
  Stream<AppResult<Cohort>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single cohort',
      extra: {'id': id},
    );
    final query = _db.select(_db.cohortsDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking cohort exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('cohort not found');
      yield AppResult.failure(
        AppException(
          'cohort with ID $id not found',
          code: .cohortNotFound,
        ),
      );
    }
    logDebug('cohort found. start watching cohort');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
