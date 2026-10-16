import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/data/data.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Implementation of [IAcademicTermRepository]
@LazySingleton(as: IAcademicTermRepository, env: [Environment.prod])
class AcademicTermRepository
    with AppLoggerMixin
    implements IAcademicTermRepository {
  /// Creates new [AcademicTermRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete academic term query', extra: {'id': id});
      final query = _db.delete(_db.academicTermsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting academic term');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicTerm>> save(CreateAcademicTermParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing academic term name query',
        extra: {'name': args.name, 'academicYearId': args.academicYearId},
      );
      final query = _db.select(_db.academicTermsDrift)
        ..where(
          (tbl) =>
              tbl.academicYearId.equals(args.academicYearId) &
              tbl.name.equals(args.name),
        );
      logDebug('start getting existing academic term name');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('academic term name exists');
        return AppResult.failure(
          AppException(
            'academic term with name ${args.name} already exists in '
            'academic year ${args.academicYearId}',
            code: .academicTermAlreadyExists,
          ),
        );
      }
      logDebug('academic term name not exists. start insert query');
      final id = _uidGenerator.generate();
      final termInsert = AcademicTermsDriftCompanion.insert(
        id: id,
        academicYearId: args.academicYearId,
        name: args.name,
        startDate: args.startDate,
        endDate: args.endDate,
      );
      logDebug('start inserting academic term');
      final termDb = await _db
          .into(_db.academicTermsDrift)
          .insertReturning(termInsert);
      logDebug('academic term inserted');
      return AppResult.success(termDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicTerm>> update(
    String id, {
    required UpdateAcademicTermParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check academic term query', extra: {'id': id});
      final query = _db.select(_db.academicTermsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking academic term');
      final termDb = await query.getSingleOrNull();
      if (termDb == null) {
        logDebug('academic term not found');
        return AppResult.failure(
          AppException(
            'academic term with id $id not found',
            code: .academicTermNotFound,
          ),
        );
      }
      logDebug('academic term found');
      if (args.name != null) {
        final targetAcademicYearId =
            args.academicYearId ?? termDb.academicYearId;
        logDebug(
          'construct checking existing name query',
          extra: {'name': args.name, 'academicYearId': targetAcademicYearId},
        );
        final existingNameQuery = _db.select(_db.academicTermsDrift)
          ..where(
            (tbl) =>
                tbl.name.equals(args.name!) &
                tbl.academicYearId.equals(targetAcademicYearId),
          );
        logDebug('start checking existing name');
        final nameExists = await existingNameQuery.getSingleOrNull();
        if (nameExists != null && nameExists.id != id) {
          logDebug('academic term name already exists');
          return AppResult.failure(
            AppException(
              'academic term with name ${args.name} '
              'within same academic year already exists',
              code: .academicTermAlreadyExists,
            ),
          );
        }
      }
      logDebug('name check passed. construct update query');
      final updateQuery = _db.update(_db.academicTermsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating academic term');
      final termsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedTermDb = termsDb.first;
      logDebug('academic term updated');
      return AppResult.success(updatedTermDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<AcademicTerm>>> watch() {
    logDebug('construct select academic terms query');
    final query = _db.select(_db.academicTermsDrift);
    logDebug('start watching academic terms');
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
  Stream<AppResult<List<AcademicTerm>>> watchByAcademicYear(
    String academicYearId,
  ) {
    logDebug(
      'construct select academic terms by academic year query',
      extra: {'academicYearId': academicYearId},
    );
    final query = _db.select(_db.academicTermsDrift)
      ..where((tbl) => tbl.academicYearId.equals(academicYearId));
    logDebug('start watching academic terms by academic year');
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(
              this,
              Invocation.method(#watchByAcademicYear, [academicYearId]),
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
  Stream<AppResult<AcademicTerm>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single academic term',
      extra: {'id': id},
    );
    final query = _db.select(_db.academicTermsDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking academic term exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('academic term not found');
      yield AppResult.failure(
        AppException(
          'academic term with ID $id not found',
          code: .academicTermNotFound,
        ),
      );
    }
    logDebug('academic term found. start watching academic term');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
