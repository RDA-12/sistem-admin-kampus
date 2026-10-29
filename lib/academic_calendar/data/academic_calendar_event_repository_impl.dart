import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/data/data.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Implementation of [IAcademicCalendarEventRepository]
@LazySingleton(as: IAcademicCalendarEventRepository, env: [Environment.prod])
class AcademicCalendarEventRepository
    with AppLoggerMixin
    implements IAcademicCalendarEventRepository {
  /// Creates new [AcademicCalendarEventRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug(
        'construct delete academic calendar event query',
        extra: {'id': id},
      );
      final query = _db.delete(_db.academicCalendarEventsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting academic calendar event');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicCalendarEvent>> save(
    CreateAcademicCalendarEventParams args,
  ) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug('start inserting academic calendar event');
      final id = _uidGenerator.generate();
      final eventInsert = AcademicCalendarEventsDriftCompanion.insert(
        id: id,
        academicYearId: args.academicYearId,
        name: args.name,
        type: args.type,
        startDate: args.start.date,
        startHour: args.start.time.hour,
        startMinute: args.start.time.minute,
        endDate: args.end.date,
        endHour: args.end.time.hour,
        endMinute: args.end.time.minute,
        recurrence: Value(args.recurrence),
      );
      final eventDb = await _db
          .into(_db.academicCalendarEventsDrift)
          .insertReturning(eventInsert);
      logDebug('academic calendar event inserted');
      return AppResult.success(eventDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<AcademicCalendarEvent>> update(
    String id, {
    required UpdateAcademicCalendarEventParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug(
        'construct check academic calendar event query',
        extra: {'id': id},
      );
      final query = _db.select(_db.academicCalendarEventsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking academic calendar event');
      final eventDb = await query.getSingleOrNull();
      if (eventDb == null) {
        logDebug('academic calendar event not found');
        return AppResult.failure(
          AppException(
            'academic calendar event with id $id not found',
            code: .academicCalendarEventNotFound,
          ),
        );
      }
      logDebug('academic calendar event found. construct update query');
      final updateQuery = _db.update(_db.academicCalendarEventsDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating academic calendar event');
      final eventsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedEventDb = eventsDb.first;
      logDebug('academic calendar event updated');
      return AppResult.success(updatedEventDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<AcademicCalendarEvent>>> watch() {
    logDebug('construct select academic calendar events query');
    final query = _db.select(_db.academicCalendarEventsDrift);
    logDebug('start watching academic calendar events');
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
  Stream<AppResult<List<AcademicCalendarEvent>>> watchByAcademicYear(
    String academicYearId,
  ) {
    logDebug(
      'construct select academic calendar events by academic year query',
      extra: {'academicYearId': academicYearId},
    );
    final query = _db.select(_db.academicCalendarEventsDrift)
      ..where((tbl) => tbl.academicYearId.equals(academicYearId));
    logDebug('start watching academic calendar events by academic year');
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
  Stream<AppResult<AcademicCalendarEvent>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single academic calendar event',
      extra: {'id': id},
    );
    final query = _db.select(_db.academicCalendarEventsDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking academic calendar event exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('academic calendar event not found');
      yield AppResult.failure(
        AppException(
          'academic calendar event with ID $id not found',
          code: .academicCalendarEventNotFound,
        ),
      );
    }
    logDebug(
      'academic calendar event found. start watching academic calendar event',
    );
    yield* query
        .watchSingle()
        .map((it) {
          maybeThrowException(this, Invocation.method(#watchSingle, [id]));
          return AppResult.success(it.toDomain());
        })
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
