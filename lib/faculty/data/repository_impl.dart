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
class FacultyRepository implements IFacultyRepository {
  /// Creates new [FacultyRepository]
  new({required this._uidGenerator, required this._db});

  final UidGenerator _uidGenerator;
  final AppDriftDatabase _db;

  @override
  Future<AppResult<Null>> delete(String id) async {
    try {
      maybeThrowException(this, Invocation.method(#delete, [id]));
      final query = _db.delete(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      await query.go();
      return AppResult.success(null);
    } on Exception catch (e) {
      return AppResult.failure(AppException('$e', code: .internal));
    }
  }

  @override
  Future<AppResult<Faculty>> save(CreateFacultyParams args) async {
    try {
      maybeThrowException(this, Invocation.method(#save, [args]));
      final query = _db.select(_db.facultiesDrift)
        ..where((tbl) => tbl.name.equals(args.name));
      final exists = await query.getSingleOrNull();
      if (exists != null) {
        return AppResult.failure(
          AppException(
            'faculty with name ${args.name} already exists',
            code: .facultyAlreadyExists,
          ),
        );
      }
      final id = _uidGenerator.generate();
      final facultyInsert = FacultiesDriftCompanion.insert(
        id: id,
        name: args.name,
      );
      final facultyDb = await _db
          .into(_db.facultiesDrift)
          .insertReturning(facultyInsert);
      return AppResult.success(facultyDb.toDomain());
    } on Exception catch (e) {
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
      final query = _db.select(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      final facultyDb = await query.getSingleOrNull();
      if (facultyDb == null) {
        return AppResult.failure(
          AppException('faculty with id $id not found', code: .facultyNotFound),
        );
      }
      final updateQuery = _db.update(_db.facultiesDrift)
        ..where((tbl) => tbl.id.equals(id));
      final facultiesDb = await updateQuery.writeReturning(args.toCompanion());
      final updatedFacultyDb = facultiesDb.first;
      return AppResult.success(updatedFacultyDb.toDomain());
    } on Exception catch (e) {
      return AppFailure(exception: AppException('$e', code: .internal));
    }
  }

  @override
  Stream<AppResult<List<Faculty>>> watch() {
    final query = _db.select(_db.facultiesDrift);
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
}
