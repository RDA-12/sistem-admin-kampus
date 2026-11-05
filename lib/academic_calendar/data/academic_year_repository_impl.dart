import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/data/data.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Implementation of [IAcademicYearRepository]
@LazySingleton(as: IAcademicYearRepository, env: [Environment.prod])
class AcademicYearRepository
    with AppLoggerMixin
    implements IAcademicYearRepository {
  /// Creates new [AcademicYearRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete academic year query', extra: {'id': id});
      final query = _db.delete(_db.academicYearsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting academic year');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicYear>> save(CreateAcademicYearParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing academic year name query',
        extra: {'name': args.name},
      );
      final query = _db.select(_db.academicYearsDrift)
        ..where((tbl) => tbl.name.equals(args.name));
      logDebug('start getting existing academic year name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('academic year name exists');
        return AppResult.failure(
          AppException(
            'academic year with name ${args.name} already exists',
            code: .academicYearAlreadyExists,
          ),
        );
      }
      logDebug('academic year name not exists. start insert query');
      final id = _uidGenerator.generate();
      final yearInsert = AcademicYearsDriftCompanion.insert(
        id: id,
        name: args.name,
        startDate: args.startDate,
        endDate: args.endDate,
      );
      logDebug('start inserting academic year');
      final yearDb = await _db
          .into(_db.academicYearsDrift)
          .insertReturning(yearInsert);
      logDebug('academic year inserted');
      return AppResult.success(yearDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicYear>> update(
    String id, {
    required UpdateAcademicYearParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check academic year query', extra: {'id': id});
      final query = _db.select(_db.academicYearsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking academic year');
      final yearDb = await query.getSingleOrNull();
      if (yearDb == null) {
        logDebug('academic year not found');
        return AppResult.failure(
          AppException(
            'academic year with id $id not found',
            code: .academicYearNotFound,
          ),
        );
      }
      logDebug('academic year found');
      if (args.name != null && args.name != yearDb.name) {
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name},
        );
        final existingNameQuery = _db.select(_db.academicYearsDrift)
          ..where((tbl) => tbl.name.equals(args.name!));
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null) {
          logDebug('academic year name already exists');
          return AppResult.failure(
            AppException(
              'academic year with name ${args.name} already exists',
              code: .academicYearAlreadyExists,
            ),
          );
        }
      }
      logDebug('name check passed. construct update query');
      final updateQuery = _db.update(_db.academicYearsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating academic year');
      final yearsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedYearDb = yearsDb.first;
      logDebug('academic year updated');
      return AppResult.success(updatedYearDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<AcademicYear>>> watch([NoFilter? filter]) {
    logDebug('construct select academic years query');
    final query = _db.select(_db.academicYearsDrift);
    logDebug('start watching academic years');
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
  Stream<AppResult<AcademicYear>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single academic year',
      extra: {'id': id},
    );
    final query = _db.select(_db.academicYearsDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking academic year exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('academic year not found');
      yield AppResult.failure(
        AppException(
          'academic year with ID $id not found',
          code: .academicYearNotFound,
        ),
      );
    }
    logDebug('academic year found. start watching academic year');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
