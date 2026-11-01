import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/data/data.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';

/// Implementation of [ICourseScheduleEventRepository]
@LazySingleton(as: ICourseScheduleEventRepository, env: [Environment.prod])
class CourseScheduleEventRepository
    with AppLoggerMixin
    implements ICourseScheduleEventRepository {
  /// Creates new [CourseScheduleEventRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug(
        'construct delete course schedule event query',
        extra: {'id': id},
      );
      await _db.transaction(() async {
        final detailQuery = _db.delete(_db.courseScheduleEventDetailsDrift)
          ..where((tbl) => tbl.eventId.equals(id));
        await detailQuery.go();

        final baseQuery = _db.delete(_db.academicCalendarEventsDrift)
          ..where((tbl) => tbl.id.equals(id));
        await baseQuery.go();
      });
      logDebug('course schedule event deleted');
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<CourseScheduleEvent>> save(
    CreateCourseScheduleEventParams args,
  ) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug('start inserting course schedule event');
      final id = _uidGenerator.generate();
      final eventInsert = AcademicCalendarEventsDriftCompanion.insert(
        id: id,
        academicYearId: args.academicYearId,
        name: args.name,
        type: AcademicCalendarEventType.lectures,
        startDate: args.start.date,
        startHour: args.start.time.hour,
        startMinute: args.start.time.minute,
        endDate: args.end.date,
        endHour: args.end.time.hour,
        endMinute: args.end.time.minute,
        recurrence: Value(args.recurrence),
      );
      final detailInsert = CourseScheduleEventDetailsDriftCompanion.insert(
        eventId: id,
        cohortId: args.courseDetail.cohortId,
        courseId: args.courseDetail.courseId,
        programId: args.courseDetail.programId,
        lecturerId: args.courseDetail.lecturerId,
        roomId: args.courseDetail.roomId,
      );

      final result = await _db.transaction(() async {
        final baseEventDb = await _db
            .into(_db.academicCalendarEventsDrift)
            .insertReturning(eventInsert);
        final detailDb = await _db
            .into(_db.courseScheduleEventDetailsDrift)
            .insertReturning(detailInsert);
        return baseEventDb.toCourseScheduleDomain(detailDb);
      });

      logDebug('course schedule event inserted');
      return AppResult.success(result);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<CourseScheduleEvent>> update(
    String id, {
    required UpdateCourseScheduleEventParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug(
        'construct check course schedule event query',
        extra: {'id': id},
      );
      final query = _db.select(_db.academicCalendarEventsDrift).join([
        innerJoin(
          _db.courseScheduleEventDetailsDrift,
          _db.courseScheduleEventDetailsDrift.eventId.equalsExp(
            _db.academicCalendarEventsDrift.id,
          ),
        ),
      ])..where(_db.academicCalendarEventsDrift.id.equals(id));

      logDebug('start checking course schedule event');
      final row = await query.getSingleOrNull();
      if (row == null) {
        logDebug('course schedule event not found');
        return AppResult.failure(
          AppException(
            'course schedule event with id $id not found',
            code: .academicCalendarEventNotFound,
          ),
        );
      }
      logDebug('course schedule event found. start updating');
      final result = await _db.transaction(() async {
        final updateBaseQuery = _db.update(_db.academicCalendarEventsDrift)
          ..where((tbl) => tbl.id.equals(id));
        final updatedBaseEvents = await updateBaseQuery.writeReturning(
          args.toBaseEventCompanion(),
        );
        final updatedBaseDb = updatedBaseEvents.first;

        final updateDetailQuery = _db.update(
          _db.courseScheduleEventDetailsDrift,
        )..where((tbl) => tbl.eventId.equals(id));
        final updatedDetails = await updateDetailQuery.writeReturning(
          args.toDetailCompanion(),
        );
        final updatedDetailDb = updatedDetails.first;

        return updatedBaseDb.toCourseScheduleDomain(updatedDetailDb);
      });

      logDebug('course schedule event updated');
      return AppResult.success(result);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<CourseScheduleEvent>>> watch() {
    logDebug('construct select course schedule events query');
    final query = _db.select(_db.academicCalendarEventsDrift).join([
      innerJoin(
        _db.courseScheduleEventDetailsDrift,
        _db.courseScheduleEventDetailsDrift.eventId.equalsExp(
          _db.academicCalendarEventsDrift.id,
        ),
      ),
    ]);
    logDebug('start watching course schedule events');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(this, Invocation.method(#watch, null));
            return AppResult.success(
              rows.map((row) {
                final base = row.readTable(_db.academicCalendarEventsDrift);
                final detail = row.readTable(
                  _db.courseScheduleEventDetailsDrift,
                );
                return base.toCourseScheduleDomain(detail);
              }).toList(),
            );
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
  Stream<AppResult<List<CourseScheduleEvent>>> watchByAcademicYear(
    String academicYearId,
  ) {
    logDebug(
      'construct select course schedule events by academic year query',
      extra: {'academicYearId': academicYearId},
    );
    final query =
        _db.select(_db.academicCalendarEventsDrift).join([
          innerJoin(
            _db.courseScheduleEventDetailsDrift,
            _db.courseScheduleEventDetailsDrift.eventId.equalsExp(
              _db.academicCalendarEventsDrift.id,
            ),
          ),
        ])..where(
          _db.academicCalendarEventsDrift.academicYearId.equals(academicYearId),
        );

    logDebug('start watching course schedule events by academic year');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(
              this,
              Invocation.method(#watchByAcademicYear, [academicYearId]),
            );
            return AppResult.success(
              rows.map((row) {
                final base = row.readTable(_db.academicCalendarEventsDrift);
                final detail = row.readTable(
                  _db.courseScheduleEventDetailsDrift,
                );
                return base.toCourseScheduleDomain(detail);
              }).toList(),
            );
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
  Stream<AppResult<List<CourseScheduleEvent>>> watchByCohort(String cohortId) {
    logDebug(
      'construct select course schedule events by cohort query',
      extra: {'cohortId': cohortId},
    );
    final query =
        _db.select(_db.academicCalendarEventsDrift).join([
          innerJoin(
            _db.courseScheduleEventDetailsDrift,
            _db.courseScheduleEventDetailsDrift.eventId.equalsExp(
              _db.academicCalendarEventsDrift.id,
            ),
          ),
        ])..where(
          _db.courseScheduleEventDetailsDrift.cohortId.equals(cohortId),
        );

    logDebug('start watching course schedule events by cohort');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(
              this,
              Invocation.method(#watchByCohort, [cohortId]),
            );
            return AppResult.success(
              rows.map((row) {
                final base = row.readTable(_db.academicCalendarEventsDrift);
                final detail = row.readTable(
                  _db.courseScheduleEventDetailsDrift,
                );
                return base.toCourseScheduleDomain(detail);
              }).toList(),
            );
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
  Stream<AppResult<CourseScheduleEvent>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single course schedule event',
      extra: {'id': id},
    );
    final query = _db.select(_db.academicCalendarEventsDrift).join([
      innerJoin(
        _db.courseScheduleEventDetailsDrift,
        _db.courseScheduleEventDetailsDrift.eventId.equalsExp(
          _db.academicCalendarEventsDrift.id,
        ),
      ),
    ])..where(_db.academicCalendarEventsDrift.id.equals(id));

    logDebug('start checking course schedule event exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('course schedule event not found');
      yield AppResult.failure(
        AppException(
          'course schedule event with ID $id not found',
          code: .academicCalendarEventNotFound,
        ),
      );
    }
    logDebug(
      'course schedule event found. start watching course schedule event',
    );
    yield* query
        .watchSingle()
        .map((row) {
          maybeThrowException(this, Invocation.method(#watchSingle, [id]));
          final base = row.readTable(_db.academicCalendarEventsDrift);
          final detail = row.readTable(_db.courseScheduleEventDetailsDrift);
          return AppResult.success(base.toCourseScheduleDomain(detail));
        })
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
