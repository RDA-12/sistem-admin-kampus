import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../academic_calendar/domain/mocks.dart';
import '../../../cohort/domain/mocks.dart';
import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../course/domain/mocks.dart';
import '../../../lecturer/domain/mocks.dart';
import '../../../program/domain/mocks.dart';
import '../../../room/domain/mocks.dart';

void main() {
  late CourseSchedulesBloc courseSchedulesBlocMock;
  late CourseScheduleMutationBloc courseScheduleMutationBlocMock;
  late ProgramsBloc programsBlocMock;
  late AcademicYearsBloc academicYearsBlocMock;
  late AcademicTermsBloc academicTermsBlocMock;
  late CohortsBloc cohortsBlocMock;
  late CoursesBloc coursesBlocMock;
  late LecturersBloc lecturersBlocMock;
  late RoomsBloc roomsBlocMock;

  setUpAll(() {
    initializeMockDependencies();
    registerFallbackValue(
      const CourseSchedulesSubscriptionRequested(
        academicYearId: '',
        termId: '',
        programId: '',
      ),
    );
  });

  setUp(() {
    courseSchedulesBlocMock = getIt<CourseSchedulesBloc>();
    whenListen(
      courseSchedulesBlocMock,
      Stream.value(const CourseSchedulesInitial()),
      initialState: const CourseSchedulesInitial(),
    );
    when(courseSchedulesBlocMock.close).thenAnswer((_) async {});

    courseScheduleMutationBlocMock = getIt<CourseScheduleMutationBloc>();
    whenListen(
      courseScheduleMutationBlocMock,
      Stream.value(const CourseScheduleMutationState()),
      initialState: const CourseScheduleMutationState(),
    );
    when(courseScheduleMutationBlocMock.close).thenAnswer((_) async {});

    programsBlocMock = getIt<ProgramsBloc>();
    whenListen(
      programsBlocMock,
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
    when(programsBlocMock.close).thenAnswer((_) async {});

    academicYearsBlocMock = getIt<AcademicYearsBloc>();
    whenListen(
      academicYearsBlocMock,
      Stream.value(AcademicYearsLoaded(academicYearsMock)),
      initialState: AcademicYearsLoaded(academicYearsMock),
    );
    when(academicYearsBlocMock.close).thenAnswer((_) async {});

    academicTermsBlocMock = getIt<AcademicTermsBloc>();
    whenListen(
      academicTermsBlocMock,
      Stream.value(AcademicTermsLoaded(academicTermsMock)),
      initialState: AcademicTermsLoaded(academicTermsMock),
    );
    when(academicTermsBlocMock.close).thenAnswer((_) async {});

    cohortsBlocMock = getIt<CohortsBloc>();
    whenListen(
      cohortsBlocMock,
      Stream.value(CohortsLoaded(cohortsMock)),
      initialState: CohortsLoaded(cohortsMock),
    );
    when(cohortsBlocMock.close).thenAnswer((_) async {});

    coursesBlocMock = getIt<CoursesBloc>();
    whenListen(
      coursesBlocMock,
      Stream.value(CoursesLoaded(coursesUIMock)),
      initialState: CoursesLoaded(coursesUIMock),
    );
    when(coursesBlocMock.close).thenAnswer((_) async {});

    lecturersBlocMock = getIt<LecturersBloc>();
    whenListen(
      lecturersBlocMock,
      Stream.value(LecturersLoaded(lecturersUIMock)),
      initialState: LecturersLoaded(lecturersUIMock),
    );
    when(lecturersBlocMock.close).thenAnswer((_) async {});

    roomsBlocMock = getIt<RoomsBloc>();
    whenListen(
      roomsBlocMock,
      Stream.value(RoomsLoaded(roomsUIMock)),
      initialState: RoomsLoaded(roomsUIMock),
    );
    when(roomsBlocMock.close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(courseSchedulesBlocMock);
    reset(courseScheduleMutationBlocMock);
    reset(programsBlocMock);
    reset(academicYearsBlocMock);
    reset(academicTermsBlocMock);
    reset(cohortsBlocMock);
    reset(coursesBlocMock);
    reset(lecturersBlocMock);
    reset(roomsBlocMock);
  });

  Future<void> pumpWidget(WidgetTester tester, {Size? phoneSize}) {
    return tester.pumpPageForTest(
      path: '/course-schedules',
      page: const CourseSchedulePage(),
      phoneSize: phoneSize,
    );
  }

  group('CourseSchedulePage', () {
    group('Init', () {
      testWidgets('adds ProgramsSubscriptionRequested to ProgramsBloc', (
        tester,
      ) async {
        await pumpWidget(tester);

        verify(
          () => programsBlocMock.add(const ProgramsSubscriptionRequested()),
        ).called(1);
      });

      testWidgets(
        'adds AcademicYearsSubscriptionRequested to AcademicYearsBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => academicYearsBlocMock.add(
              const AcademicYearsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'adds AcademicTermsSubscriptionRequested to AcademicTermsBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => academicTermsBlocMock.add(
              const AcademicTermsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Jadwal Perkuliahan'), findsOneWidget);
      });

      testWidgets('provides CourseSchedulesBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<CourseSchedulesBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides CourseScheduleMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<CourseScheduleMutationBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides ProgramsBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<ProgramsBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides AcademicYearsBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<AcademicYearsBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides AcademicTermsBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<AcademicTermsBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides CohortsBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<CohortsBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides CoursesBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<CoursesBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides LecturersBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<LecturersBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides RoomsBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<RoomsBloc>),
          findsOneWidget,
        );
      });

      testWidgets('shows CourseScheduleCalendarView', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CourseScheduleCalendarView), findsOneWidget);
      });

      testWidgets('shows CourseScheduleCalendarView in compact screen', (
        tester,
      ) async {
        await pumpWidget(tester, phoneSize: const Size(450, 800));

        expect(find.byType(CourseScheduleCalendarView), findsOneWidget);
      });

      testWidgets('shows CourseScheduleCalendarView in medium screen', (
        tester,
      ) async {
        await pumpWidget(tester, phoneSize: const Size(650, 800));

        expect(find.byType(CourseScheduleCalendarView), findsOneWidget);
      });

      testWidgets('shows CourseScheduleCalendarView in expanded screen', (
        tester,
      ) async {
        await pumpWidget(tester, phoneSize: const Size(850, 800));

        expect(find.byType(CourseScheduleCalendarView), findsOneWidget);
      });

      testWidgets('shows CourseScheduleCalendarView in large screen', (
        tester,
      ) async {
        await pumpWidget(tester, phoneSize: const Size(1250, 800));

        expect(find.byType(CourseScheduleCalendarView), findsOneWidget);
      });
    });
  });
}
