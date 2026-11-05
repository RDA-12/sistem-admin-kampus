import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

void main() {
  late AppDriftDatabase database;

  setUp(() {
    database = AppDriftDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('CourseScheduleFilterX', () {
    const year1Id = 'year_1';
    const year2Id = 'year_2';
    const term1Id = 'term_1';
    const term2Id = 'term_2';
    const program1Id = 'program_1';
    const program2Id = 'program_2';
    const cohort1Id = 'cohort_1';
    const cohort2Id = 'cohort_2';

    final date = DateTime(2025, 9);

    setUp(() async {
      await database.into(database.academicYearsDrift).insert(
        AcademicYearsDriftCompanion.insert(
          id: year1Id,
          name: '2025/2026',
          startDate: date,
          endDate: DateTime(2026, 8, 31),
        ),
      );
      await database.into(database.academicYearsDrift).insert(
        AcademicYearsDriftCompanion.insert(
          id: year2Id,
          name: '2026/2027',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2027, 8, 31),
        ),
      );
      await database.into(database.academicTermsDrift).insert(
        AcademicTermsDriftCompanion.insert(
          id: term1Id,
          academicYearId: year1Id,
          name: 'Ganjil',
          startDate: date,
          endDate: DateTime(2026, 1, 31),
        ),
      );
      await database.into(database.academicTermsDrift).insert(
        AcademicTermsDriftCompanion.insert(
          id: term2Id,
          academicYearId: year2Id,
          name: 'Genap',
          startDate: DateTime(2027, 2),
          endDate: DateTime(2027, 6, 30),
        ),
      );
      await database.into(database.facultiesDrift).insert(
        FacultiesDriftCompanion.insert(
          id: 'faculty_1',
          name: 'Faculty 1',
        ),
      );
      await database.into(database.programsDrift).insert(
        ProgramsDriftCompanion.insert(
          id: program1Id,
          facultyId: 'faculty_1',
          name: 'Program 1',
        ),
      );
      await database.into(database.programsDrift).insert(
        ProgramsDriftCompanion.insert(
          id: program2Id,
          facultyId: 'faculty_1',
          name: 'Program 2',
        ),
      );
      await database.into(database.cohortsDrift).insert(
        CohortsDriftCompanion.insert(
          id: cohort1Id,
          name: 'Cohort 2025',
          entryYear: 2025,
        ),
      );
      await database.into(database.cohortsDrift).insert(
        CohortsDriftCompanion.insert(
          id: cohort2Id,
          name: 'Cohort 2026',
          entryYear: 2026,
        ),
      );
      await database.into(database.coursesDrift).insert(
        CoursesDriftCompanion.insert(
          id: 'course_1',
          programId: program1Id,
          code: 'CS101',
          name: 'Course 1',
          semester: 1,
          credit: 3,
        ),
      );
      await database.into(database.coursesDrift).insert(
        CoursesDriftCompanion.insert(
          id: 'course_2',
          programId: program2Id,
          code: 'CS201',
          name: 'Course 2',
          semester: 2,
          credit: 3,
        ),
      );
      await database.into(database.lecturersDrift).insert(
        LecturersDriftCompanion.insert(
          id: 'lecturer_1',
          programId: program1Id,
          name: 'Lecturer 1',
          pangkatGolongan: 'III/a',
        ),
      );
      await database.into(database.lecturersDrift).insert(
        LecturersDriftCompanion.insert(
          id: 'lecturer_2',
          programId: program2Id,
          name: 'Lecturer 2',
          pangkatGolongan: 'III/b',
        ),
      );
      await database.into(database.roomsDrift).insert(
        RoomsDriftCompanion.insert(
          id: 'room_1',
          facultyId: 'faculty_1',
          name: 'Room 1',
        ),
      );
      await database.into(database.roomsDrift).insert(
        RoomsDriftCompanion.insert(
          id: 'room_2',
          facultyId: 'faculty_1',
          name: 'Room 2',
        ),
      );
      await database.into(database.courseSchedulesDrift).insert(
        CourseSchedulesDriftCompanion.insert(
          id: 'schedule_1',
          academicYearId: year1Id,
          termId: term1Id,
          programId: program1Id,
          name: 'Schedule 1',
          start: DateTime(2025, 9, 8, 8),
          durationInMinutes: 100,
          cohortId: cohort1Id,
          courseId: 'course_1',
          lecturerId: 'lecturer_1',
          roomId: 'room_1',
        ),
      );
      await database.into(database.courseSchedulesDrift).insert(
        CourseSchedulesDriftCompanion.insert(
          id: 'schedule_2',
          academicYearId: year2Id,
          termId: term2Id,
          programId: program2Id,
          name: 'Schedule 2',
          start: DateTime(2026, 9, 8, 8),
          durationInMinutes: 100,
          cohortId: cohort2Id,
          courseId: 'course_2',
          lecturerId: 'lecturer_2',
          roomId: 'room_2',
        ),
      );
    });

    test('applies where clause when academicYearId is provided', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter(
        academicYearId: year1Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'schedule_1');
      expect(result.first.academicYearId, year1Id);
    });

    test('applies where clause when cohortId is provided', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter(
        cohortId: cohort2Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'schedule_2');
      expect(result.first.cohortId, cohort2Id);
    });

    test('applies where clause when termId is provided', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter(
        termId: term1Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'schedule_1');
      expect(result.first.termId, term1Id);
    });

    test('applies where clause when programId is provided', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter(
        programId: program2Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'schedule_2');
      expect(result.first.programId, program2Id);
    });

    test('applies multiple filter clauses simultaneously', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter(
        academicYearId: year1Id,
        cohortId: cohort1Id,
        termId: term1Id,
        programId: program1Id,
      ).apply(initialQuery);
      final result = await query.get();

      expect(result.length, 1);
      expect(result.first.id, 'schedule_1');
    });

    test(
      'returns empty list when conflicting filter criteria do not match',
      () async {
        final initialQuery = database.select(database.courseSchedulesDrift);
        final query = const CourseScheduleFilter(
          academicYearId: year1Id,
          programId: program2Id,
        ).apply(initialQuery);
        final result = await query.get();

        expect(result, isEmpty);
      },
    );

    test('returns unmodified query when all filter fields are null', () async {
      final initialQuery = database.select(database.courseSchedulesDrift);
      final query = const CourseScheduleFilter().apply(initialQuery);
      final result = await query.get();

      expect(result.length, 2);
      expect(
        result.map((e) => e.id),
        containsAll(['schedule_1', 'schedule_2']),
      );
    });
  });
}
