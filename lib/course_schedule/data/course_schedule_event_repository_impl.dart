import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/data/data.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';

/// Implementation of [ICourseScheduleRepository]
@LazySingleton(as: ICourseScheduleRepository, env: [Environment.prod])
class CourseScheduleRepository
    with AppLoggerMixin
    implements ICourseScheduleRepository {
  /// Creates new [CourseScheduleRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug(
        'construct delete course schedule query',
        extra: {'id': id},
      );
      final query = _db.delete(_db.courseSchedulesDrift)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();
      logDebug('course schedule deleted');
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<CourseSchedule>> save(
    CreateCourseScheduleParams args,
  ) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug('start inserting course schedule');
      final id = _uidGenerator.generate();
      final insert = CourseSchedulesDriftCompanion.insert(
        id: id,
        academicYearId: args.academicYearId,
        termId: args.termId,
        programId: args.programId,
        name: args.name,
        start: args.start,
        durationInMinutes: args.duration.inMinutes,
        cohortId: args.cohortId,
        courseId: args.courseId,
        lecturerId: args.lecturerId,
        roomId: args.roomId,
      );
      final resultDb = await _db
          .into(_db.courseSchedulesDrift)
          .insertReturning(insert);
      logDebug('course schedule inserted');
      return AppResult.success(resultDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<CourseSchedule>> update(
    String id, {
    required UpdateCourseScheduleParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug(
        'construct check course schedule query',
        extra: {'id': id},
      );
      final query = _db.select(_db.courseSchedulesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking course schedule');
      final row = await query.getSingleOrNull();
      if (row == null) {
        logDebug('course schedule not found');
        return AppResult.failure(
          AppException(
            'course schedule with id $id not found',
            code: .courseScheduleNotFound,
          ),
        );
      }
      logDebug('course schedule found. start updating');
      final updateQuery = _db.update(_db.courseSchedulesDrift)
        ..where((tbl) => tbl.id.equals(id));
      final updatedRows = await updateQuery.writeReturning(args.toCompanion());
      logDebug('course schedule updated');
      return AppResult.success(updatedRows.first.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<CourseSchedule>>> watch() {
    logDebug('construct select course schedules query');
    final query = _db.select(_db.courseSchedulesDrift);
    logDebug('start watching course schedules');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(this, Invocation.method(#watch, null));
            return AppResult.success(
              rows.map((row) => row.toDomain()).toList(),
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
  Stream<AppResult<List<CourseSchedule>>> watchByAcademicYear(
    String academicYearId,
  ) {
    logDebug(
      'construct select course schedules by academic year query',
      extra: {'academicYearId': academicYearId},
    );
    final query = _db.select(_db.courseSchedulesDrift)
      ..where((tbl) => tbl.academicYearId.equals(academicYearId));

    logDebug('start watching course schedules by academic year');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(
              this,
              Invocation.method(#watchByAcademicYear, [academicYearId]),
            );
            return AppResult.success(
              rows.map((row) => row.toDomain()).toList(),
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
  Stream<AppResult<List<CourseSchedule>>> watchByCohort(String cohortId) {
    logDebug(
      'construct select course schedules by cohort query',
      extra: {'cohortId': cohortId},
    );
    final query = _db.select(_db.courseSchedulesDrift)
      ..where((tbl) => tbl.cohortId.equals(cohortId));

    logDebug('start watching course schedules by cohort');
    return query
        .watch()
        .map(
          (rows) {
            maybeThrowException(
              this,
              Invocation.method(#watchByCohort, [cohortId]),
            );
            return AppResult.success(
              rows.map((row) => row.toDomain()).toList(),
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
  Stream<AppResult<CourseSchedule>> watchSingle(String id) async* {
    logDebug(
      'construct select query for single course schedule',
      extra: {'id': id},
    );
    final query = _db.select(_db.courseSchedulesDrift)
      ..where((tbl) => tbl.id.equals(id));

    logDebug('start checking course schedule exists or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('course schedule not found');
      yield AppResult.failure(
        AppException(
          'course schedule with ID $id not found',
          code: .courseScheduleNotFound,
        ),
      );
    }
    logDebug(
      'course schedule found. start watching course schedule',
    );
    yield* query
        .watchSingle()
        .map((row) {
          maybeThrowException(this, Invocation.method(#watchSingle, [id]));
          return AppResult.success(row.toDomain());
        })
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
