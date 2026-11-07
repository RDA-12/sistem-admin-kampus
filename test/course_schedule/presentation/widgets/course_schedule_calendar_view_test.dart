import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../academic_calendar/domain/mocks.dart';
import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late CourseSchedulesBloc courseSchedulesBlocMock;
  late ProgramsBloc programsBlocMock;
  late AcademicYearsBloc academicYearsBlocMock;
  late AcademicTermsBloc academicTermsBlocMock;

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
  });

  tearDown(() {
    reset(courseSchedulesBlocMock);
    reset(programsBlocMock);
    reset(academicYearsBlocMock);
    reset(academicTermsBlocMock);
  });

  Future<void> pumpWidget(WidgetTester tester) {
    return tester.pumpWidgetForTest(
      (context) {
        return const CourseScheduleCalendarView();
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: courseSchedulesBlocMock),
            BlocProvider.value(value: programsBlocMock),
            BlocProvider.value(value: academicYearsBlocMock),
            BlocProvider.value(value: academicTermsBlocMock),
          ],
          child: child,
        );
      },
    );
  }

  group('CourseScheduleCalendarView', () {
    group('Render', () {
      testWidgets('shows ProgramSelector with correct label', (tester) async {
        await pumpWidget(tester);

        final finder = find.byType(ProgramSelector);
        expect(finder, findsOneWidget);
        final widget = tester.widget<ProgramSelector>(finder);
        expect(widget.label, 'Program Studi');
      });

      testWidgets(
        'shows AcademicYearSelector with correct label',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicYearSelector);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearSelector>(finder);
          expect(widget.label, 'Tahun Akademik');
        },
      );

      testWidgets(
        'shows AcademicTermSelector with correct label',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicTermSelector);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicTermSelector>(finder);
          expect(widget.label, 'Semester');
        },
      );

      testWidgets(
        'shows AppEmptyBox with correct message when state is initial',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(
            widget.message,
            'Pilih Program Studi, Tahun Akademik, dan Semester '
            'untuk melihat jadwal perkuliahan program studi yang dipilih',
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            courseSchedulesBlocMock,
            Stream.value(const CourseSchedulesLoadData()),
            initialState: const CourseSchedulesLoadData(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows LoadingIndicator on state stream transition',
        (tester) async {
          final controller = StreamController<CourseSchedulesState>.broadcast();
          when(() => courseSchedulesBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(const CourseSchedulesLoadData());
          await tester.pump();

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          const exception = AppException(
            'something went wrong',
            code: .internal,
          );
          whenListen(
            courseSchedulesBlocMock,
            Stream.value(const CourseSchedulesLoadFailed(exception)),
            initialState: const CourseSchedulesLoadFailed(exception),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal memuat jadwal kuliah');
          expect(widget.exception, exception);
        },
      );

      testWidgets(
        'shows AppEmptyBox when state is loaded with empty schedules',
        (tester) async {
          final emptyCalendar = CourseScheduleCalendarUI(
            academicCalendar: AcademicCalendar(year: academicYearMock),
            schedules: const [],
          );
          whenListen(
            courseSchedulesBlocMock,
            Stream.value(CourseSchedulesLoaded(emptyCalendar)),
            initialState: CourseSchedulesLoaded(emptyCalendar),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppEmptyBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppEmptyBox>(finder);
          expect(widget.message, 'Tidak ada jadwal yang tersimpan');
        },
      );

      testWidgets(
        'shows CourseScheduleCalendar when state is loaded with schedules',
        (tester) async {
          whenListen(
            courseSchedulesBlocMock,
            Stream.value(
              CourseSchedulesLoaded(courseScheduleCalendarUIMock),
            ),
            initialState:
                CourseSchedulesLoaded(courseScheduleCalendarUIMock),
          );

          await pumpWidget(tester);

          expect(find.byType(CourseScheduleCalendar), findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'does not trigger CourseSchedulesSubscriptionRequested when '
        'only program is selected',
        (tester) async {
          await pumpWidget(tester);

          final programSelector = tester.widget<ProgramSelector>(
            find.byType(ProgramSelector),
          );
          programSelector.controller.selected = programsUIMock.first;
          await tester.pump();

          verifyNever(
            () => courseSchedulesBlocMock.add(any()),
          );
        },
      );

      testWidgets(
        'does not trigger CourseSchedulesSubscriptionRequested when '
        'only program and year are selected',
        (tester) async {
          await pumpWidget(tester);

          final programSelector = tester.widget<ProgramSelector>(
            find.byType(ProgramSelector),
          );
          final yearSelector = tester.widget<AcademicYearSelector>(
            find.byType(AcademicYearSelector),
          );

          programSelector.controller.selected = programsUIMock.first;
          yearSelector.controller.selected = academicYearsMock.first;
          await tester.pump();

          verifyNever(
            () => courseSchedulesBlocMock.add(any()),
          );
        },
      );

      testWidgets(
        'does not trigger CourseSchedulesSubscriptionRequested when '
        'only year and term are selected',
        (tester) async {
          await pumpWidget(tester);

          final yearSelector = tester.widget<AcademicYearSelector>(
            find.byType(AcademicYearSelector),
          );
          final termSelector = tester.widget<AcademicTermSelector>(
            find.byType(AcademicTermSelector),
          );

          yearSelector.controller.selected = academicYearsMock.first;
          termSelector.controller.selected = academicTermsMock.first;
          await tester.pump();

          verifyNever(
            () => courseSchedulesBlocMock.add(any()),
          );
        },
      );

      testWidgets(
        'triggers CourseSchedulesSubscriptionRequested when program, '
        'academic year, and academic term are selected',
        (tester) async {
          await pumpWidget(tester);

          final programSelector = tester.widget<ProgramSelector>(
            find.byType(ProgramSelector),
          );
          final yearSelector = tester.widget<AcademicYearSelector>(
            find.byType(AcademicYearSelector),
          );
          final termSelector = tester.widget<AcademicTermSelector>(
            find.byType(AcademicTermSelector),
          );

          programSelector.controller.selected = programsUIMock.first;
          yearSelector.controller.selected = academicYearsMock.first;
          termSelector.controller.selected = academicTermsMock.first;
          await tester.pump();

          verify(
            () => courseSchedulesBlocMock.add(
              CourseSchedulesSubscriptionRequested(
                academicYearId: academicYearsMock.first.id,
                termId: academicTermsMock.first.id,
                programId: programsUIMock.first.id,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'triggers CourseSchedulesSubscriptionRequested again when '
        'a filter changes',
        (tester) async {
          await pumpWidget(tester);

          final programSelector = tester.widget<ProgramSelector>(
            find.byType(ProgramSelector),
          );
          final yearSelector = tester.widget<AcademicYearSelector>(
            find.byType(AcademicYearSelector),
          );
          final termSelector = tester.widget<AcademicTermSelector>(
            find.byType(AcademicTermSelector),
          );

          programSelector.controller.selected = programsUIMock.first;
          yearSelector.controller.selected = academicYearsMock.first;
          termSelector.controller.selected = academicTermsMock.first;
          await tester.pump();

          termSelector.controller.selected = academicTermsMock[1];
          await tester.pump();

          verify(
            () => courseSchedulesBlocMock.add(
              CourseSchedulesSubscriptionRequested(
                academicYearId: academicYearsMock.first.id,
                termId: academicTermsMock[1].id,
                programId: programsUIMock.first.id,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'does not trigger CourseSchedulesSubscriptionRequested when '
        'one of selected filters becomes null',
        (tester) async {
          await pumpWidget(tester);

          final programSelector = tester.widget<ProgramSelector>(
            find.byType(ProgramSelector),
          );
          final yearSelector = tester.widget<AcademicYearSelector>(
            find.byType(AcademicYearSelector),
          );
          final termSelector = tester.widget<AcademicTermSelector>(
            find.byType(AcademicTermSelector),
          );

          programSelector.controller.selected = programsUIMock.first;
          yearSelector.controller.selected = academicYearsMock.first;
          termSelector.controller.selected = academicTermsMock.first;
          await tester.pump();

          clearInteractions(courseSchedulesBlocMock);

          termSelector.controller.selected = null;
          await tester.pump();

          verifyNever(
            () => courseSchedulesBlocMock.add(any()),
          );
        },
      );
    });
  });
}
