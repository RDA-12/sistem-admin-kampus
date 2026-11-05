import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/data/data.dart';
import 'package:sistem_admin/course/domain/domain.dart';

/// Implementation of [ICourseRepository]
@LazySingleton(as: ICourseRepository, env: [Environment.prod])
class CourseRepository with AppLoggerMixin implements ICourseRepository {
  /// Creates new [CourseRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      logDebug('construct delete course query', extra: {'id': id});
      final query = _db.delete(_db.coursesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start deleting course');
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Course>> save(CreateCourseParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      logDebug(
        'construct get existing course code query',
        extra: {'code': args.code, 'programId': args.programId},
      );
      final query = _db.select(_db.coursesDrift)
        ..where(
          (tbl) =>
              tbl.programId.equals(args.programId) & tbl.code.equals(args.code),
        );
      logDebug('start getting existing course code');
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        logDebug('course code exists');
        return AppResult.failure(
          AppException(
            'course with code ${args.code} already exists in '
            'program ${args.programId}',
            code: .courseAlreadyExists,
          ),
        );
      }
      logDebug('course code not exists. start insert course query');
      final id = _uidGenerator.generate();
      final courseInsert = CoursesDriftCompanion.insert(
        id: id,
        programId: args.programId,
        code: args.code,
        name: args.name,
        semester: args.semester,
        credit: args.credit,
      );
      logDebug('start inserting course');
      final courseDb = await _db
          .into(_db.coursesDrift)
          .insertReturning(courseInsert);
      logDebug('course inserted');
      return AppResult.success(courseDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Course>> update(
    String id, {
    required UpdateCourseParams args,
  }) async {
    try {
      maybeThrowException(
        this,
        Invocation.method(#update, [id], {#args: args}),
      );
      logDebug('construct check course query', extra: {'id': id});
      final query = _db.select(_db.coursesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start checking course');
      final courseDb = await query.getSingleOrNull();
      if (courseDb == null) {
        logDebug('course not found');
        return AppResult.failure(
          AppException(
            'course with id $id not found',
            code: .courseNotFound,
          ),
        );
      }
      logDebug('course found');
      final targetProgramId = args.programId ?? courseDb.programId;
      if (args.code != null) {
        logDebug(
          'construct checking existing code query',
          extra: {'code': args.code, 'programId': targetProgramId},
        );
        final existingCodeQuery = _db.select(_db.coursesDrift)
          ..where(
            (tbl) =>
                tbl.code.equals(args.code!) &
                tbl.programId.equals(targetProgramId),
          );
        logDebug('start checking existing code');
        final codeExists = await existingCodeQuery.getSingleOrNull();
        if (codeExists != null && codeExists.id != id) {
          logDebug('course code already exists');
          return AppResult.failure(
            AppException(
              'course with code ${args.code} '
              'within same program already exists',
              code: .courseAlreadyExists,
            ),
          );
        }
      }
      logDebug('course code not found. construct update query');
      final updateQuery = _db.update(_db.coursesDrift)
        ..where((tbl) => tbl.id.equals(id));
      logDebug('start updating course');
      final coursesDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedCourseDb = coursesDb.first;
      logDebug('course updated');
      return AppResult.success(updatedCourseDb.toDomain());
    } on Exception catch (e, st) {
      logError('$e', error: e, stackTrace: st);
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Course>>> watch([CourseFilter? filter]) {
    logDebug('construct select courses query', extra: {'filter': filter});
    var query = _db.select(_db.coursesDrift);
    if (filter != null) {
      query = filter.apply(query);
    }
    logDebug('start watching courses');
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
  Stream<AppResult<Course>> watchSingle(String id) async* {
    logDebug('construct select query for single course', extra: {'id': id});
    final query = _db.select(_db.coursesDrift)
      ..where((tbl) => tbl.id.equals(id));
    logDebug('start checking course exist or not');
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      logDebug('course not found');
      yield AppResult.failure(
        AppException('course with ID $id not found', code: .courseNotFound),
      );
    }
    logDebug('course found. start watching course');
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, st) {
          logError('$error', error: error, stackTrace: st);
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
