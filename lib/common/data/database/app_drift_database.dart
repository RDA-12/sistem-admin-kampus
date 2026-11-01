import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

part 'app_drift_database.g.dart';

/// Drift database class for this app
@LazySingleton(env: [Environment.prod])
@DriftDatabase(
  tables: [
    FacultiesDrift,
    ProgramsDrift,
    LecturersDrift,
    CoursesDrift,
    RoomsDrift,
    AcademicYearsDrift,
    AcademicTermsDrift,
    AcademicCalendarEventsDrift,
    CohortsDrift,
    CourseScheduleEventDetailsDrift,
  ],
)
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
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
