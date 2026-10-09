import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:sistem_admin/faculty/faculty.dart';

part 'app_drift_database.g.dart';

/// Drift database class for this app
@LazySingleton(env: [Environment.prod])
@DriftDatabase(tables: [FacultiesDrift])
class AppDriftDatabase extends _$AppDriftDatabase {
  /// Creates new [AppDriftDatabase]
  factory() => AppDriftDatabase._(_openConnection());

  /// Creates new [AppDriftDatabase] for testing purposes
  @visibleForTesting
  factory forTesting(QueryExecutor e) => AppDriftDatabase._(e);

  /// Creates new [AppDriftDatabase]
  new _(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'sistem_admin_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}
