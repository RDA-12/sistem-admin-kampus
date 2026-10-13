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
class ProgramRepository implements IProgramRepository {
  /// Creates new [ProgramRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      final query = _db.delete(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e) {
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Program>> save(CreateProgramParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      final query = _db.select(_db.programsDrift)
        ..where(
          (tbl) =>
              tbl.facultyId.equals(args.facultyId) & tbl.name.equals(args.name),
        );
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        return AppResult.failure(
          AppException(
            'program with name ${args.name} already exists in '
            'faculty ${args.facultyId}',
            code: .programAlreadyExists,
          ),
        );
      }
      final id = _uidGenerator.generate();
      final programInsert = ProgramsDriftCompanion.insert(
        id: id,
        facultyId: args.facultyId,
        name: args.name,
      );
      final programDb = await _db
          .into(_db.programsDrift)
          .insertReturning(programInsert);
      return AppResult.success(programDb.toDomain());
    } on Exception catch (e) {
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
      final query = _db.select(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      final programDb = await query.getSingleOrNull();
      if (programDb == null) {
        return AppResult.failure(
          AppException('program with id $id not found', code: .programNotFound),
        );
      }
      final updateQuery = _db.update(_db.programsDrift)
        ..where((tbl) => tbl.id.equals(id));
      final programsDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedProgramDb = programsDb.first;
      return AppResult.success(updatedProgramDb.toDomain());
    } on Exception catch (e) {
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Program>>> watch() {
    final query = _db.select(_db.programsDrift);
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(this, Invocation.method(#watch, null));
            return AppResult.success(it.map((v) => v.toDomain()).toList());
          },
        )
        .onErrorReturnWith((error, _) {
          return AppResult.failure(
            AppException('$error', code: .internal),
          );
        });
  }

  @override
  Stream<AppResult<List<Program>>> watchByFaculty(String facultyId) {
    final query = _db.select(_db.programsDrift)
      ..where((tbl) => tbl.facultyId.equals(facultyId));
    return query
        .watch()
        .map(
          (it) {
            maybeThrowException(
              this,
              Invocation.method(#watchByFaculty, [facultyId]),
            );
            return AppResult.success(it.map((v) => v.toDomain()).toList());
          },
        )
        .onErrorReturnWith((error, _) {
          return AppResult.failure(
            AppException('$error', code: .internal),
          );
        });
  }

  @override
  Stream<AppResult<Program>> watchSingle(String id) async* {
    final query = _db.select(_db.programsDrift)
      ..where((tbl) => tbl.id.equals(id));
    final exists = await query.getSingleOrNull();
    if (exists == null) {
      yield AppResult.failure(
        AppException('program with ID $id not found', code: .programNotFound),
      );
    }
    yield* query
        .watchSingle()
        .map((it) => AppResult.success(it.toDomain()))
        .onErrorReturnWith((error, _) {
          return AppResult.failure(AppException('$error', code: .internal));
        });
  }
}
