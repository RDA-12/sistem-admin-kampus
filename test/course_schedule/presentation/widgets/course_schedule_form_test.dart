import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../cohort/domain/mocks.dart';
import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../course/domain/mocks.dart';
import '../../../lecturer/domain/mocks.dart';
import '../../../room/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final schedule = courseScheduleUIMock;
  late CourseScheduleMutationBloc courseScheduleMutationBlocMock;
  late CohortsBloc cohortsBlocMock;
  late CoursesBloc coursesBlocMock;
  late LecturersBloc lecturersBlocMock;
  late RoomsBloc roomsBlocMock;

  group('CourseScheduleForm', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      courseScheduleMutationBlocMock = getIt<CourseScheduleMutationBloc>();
      whenListen(
        courseScheduleMutationBlocMock,
        Stream.value(const CourseScheduleMutationState()),
        initialState: const CourseScheduleMutationState(),
      );

      cohortsBlocMock = getIt<CohortsBloc>();
      whenListen(
        cohortsBlocMock,
        Stream.value(CohortsLoaded(cohortsMock)),
        initialState: CohortsLoaded(cohortsMock),
      );

      coursesBlocMock = getIt<CoursesBloc>();
      whenListen(
        coursesBlocMock,
        Stream.value(CoursesLoaded(coursesUIMock)),
        initialState: CoursesLoaded(coursesUIMock),
      );

      lecturersBlocMock = getIt<LecturersBloc>();
      whenListen(
        lecturersBlocMock,
        Stream.value(LecturersLoaded(lecturersUIMock)),
        initialState: LecturersLoaded(lecturersUIMock),
      );

      roomsBlocMock = getIt<RoomsBloc>();
      whenListen(
        roomsBlocMock,
        Stream.value(RoomsLoaded(roomsUIMock)),
        initialState: RoomsLoaded(roomsUIMock),
      );
    });

    tearDown(() {
      reset(courseScheduleMutationBlocMock);
      reset(cohortsBlocMock);
      reset(coursesBlocMock);
      reset(lecturersBlocMock);
      reset(roomsBlocMock);
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      CourseScheduleUI? initial,
      String? academicYearId,
      String? termId,
      String? programId,
      void Function(CourseSchedule)? onCourseScheduleDeleted,
    }) {
      return tester.pumpWidgetForTest(
        (context) => CourseScheduleForm(
          initial: initial,
          academicYearId: academicYearId ?? 'year_1',
          termId: termId ?? 'term_1',
          programId: programId ?? 'program_1',
          onCourseScheduleDeleted: onCourseScheduleDeleted,
        ),
        phoneSize: const Size(1000, 1200),
        providerBuilder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: courseScheduleMutationBlocMock,
              ),
              BlocProvider.value(
                value: cohortsBlocMock,
              ),
              BlocProvider.value(
                value: coursesBlocMock,
              ),
              BlocProvider.value(
                value: lecturersBlocMock,
              ),
              BlocProvider.value(
                value: roomsBlocMock,
              ),
            ],
            child: child,
          );
        },
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Jadwal Kuliah *'),
      matching: find.byType(TextFormField),
    );
    final cohortSelectorFinder = find.ancestor(
      of: find.text('Angkatan *'),
      matching: find.byType(CohortSelector),
    );
    final courseSelectorFinder = find.ancestor(
      of: find.text('Mata Kuliah *'),
      matching: find.byType(CourseSelector),
    );
    final lecturerSelectorFinder = find.ancestor(
      of: find.text('Dosen *'),
      matching: find.byType(LecturerSelector),
    );
    final roomSelectorFinder = find.ancestor(
      of: find.text('Ruangan *'),
      matching: find.byType(RoomSelector),
    );
    final startDateFieldFinder = find.ancestor(
      of: find.text('Tanggal Mulai *'),
      matching: find.byType(AppDateFormField),
    );
    final timeFieldFinder = find.ancestor(
      of: find.text('Jam Mulai *'),
      matching: find.byType(TextFormField),
    );
    final durationFieldFinder = find.ancestor(
      of: find.text('Durasi (menit) *'),
      matching: find.byType(AppNumberFormField),
    );
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );
    final deleteButtonFinder = find.ancestor(
      of: find.text('Hapus'),
      matching: find.byType(AppButton),
    );

    Future<void> selectCohort(WidgetTester tester) async {
      await tester.ensureVisible(cohortSelectorFinder);
      await tester.tap(cohortSelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(cohortsMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    Future<void> selectCourse(WidgetTester tester) async {
      await tester.ensureVisible(courseSelectorFinder);
      await tester.tap(courseSelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(coursesMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    Future<void> selectLecturer(WidgetTester tester) async {
      await tester.ensureVisible(lecturerSelectorFinder);
      await tester.tap(lecturerSelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(lecturersMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    Future<void> selectRoom(WidgetTester tester) async {
      await tester.ensureVisible(roomSelectorFinder);
      await tester.tap(roomSelectorFinder);
      await tester.pumpAndSettle();
      final firstFinder = find.ancestor(
        of: find.text(roomsMock.first.name),
        matching: find.byType(CheckboxListTile),
      );
      await tester.ensureVisible(firstFinder);
      await tester.tap(firstFinder);
      await tester.pumpAndSettle();
    }

    Future<void> selectDate(
      WidgetTester tester,
      DateTime date,
    ) async {
      await tester.ensureVisible(startDateFieldFinder);
      await withClock(Clock.fixed(date), () async {
        await tester.tap(startDateFieldFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      });
    }

    group('Render', () {
      testWidgets(
        'shows name, selectors, date, time, and duration fields',
        (tester) async {
          await pumpWidget(tester);

          expect(nameFieldFinder, findsOneWidget);
          expect(cohortSelectorFinder, findsOneWidget);
          expect(courseSelectorFinder, findsOneWidget);
          expect(lecturerSelectorFinder, findsOneWidget);
          expect(roomSelectorFinder, findsOneWidget);
          expect(startDateFieldFinder, findsOneWidget);
          expect(timeFieldFinder, findsOneWidget);
          expect(durationFieldFinder, findsOneWidget);
        },
      );

      testWidgets('shows save button', (tester) async {
        await pumpWidget(tester);

        expect(saveButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator and disable save button when '
        'CourseScheduleMutationState isCreating true',
        (tester) async {
          whenListen(
            courseScheduleMutationBlocMock,
            Stream.value(const CourseScheduleMutationState(isCreating: true)),
          );

          await pumpWidget(tester);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on save button and disable it '
        'when CourseScheduleMutationState updatingIds contains initial '
        'schedule',
        (tester) async {
          whenListen(
            courseScheduleMutationBlocMock,
            Stream.value(
              CourseScheduleMutationState(updatingIds: {schedule.id}),
            ),
          );

          await pumpWidget(tester, initial: schedule);
          await tester.pump();

          expect(
            find.descendant(
              of: saveButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(tester.widget<AppButton>(saveButtonFinder).onPressed, isNull);
        },
      );

      testWidgets(
        'disable delete button '
        'when CourseScheduleMutationState updatingIds contains initial '
        'schedule',
        (tester) async {
          whenListen(
            courseScheduleMutationBlocMock,
            Stream.value(
              CourseScheduleMutationState(deletingIds: {schedule.id}),
            ),
          );

          await pumpWidget(tester, initial: schedule);
          await tester.pump();

          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'disable save button '
        'when CourseScheduleMutationState deletingIds contains initial '
        'schedule',
        (tester) async {
          whenListen(
            courseScheduleMutationBlocMock,
            Stream.value(
              CourseScheduleMutationState(deletingIds: {schedule.id}),
            ),
          );

          await pumpWidget(tester, initial: schedule);
          await tester.pump();

          expect(
            tester.widget<AppButton>(saveButtonFinder).onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'shows LoadingIndicator on delete button and disable it '
        'when CourseScheduleMutationState deletingIds contains initial '
        'schedule',
        (tester) async {
          whenListen(
            courseScheduleMutationBlocMock,
            Stream.value(
              CourseScheduleMutationState(deletingIds: {schedule.id}),
            ),
          );

          await pumpWidget(tester, initial: schedule);
          await tester.pump();

          expect(
            find.descendant(
              of: deleteButtonFinder,
              matching: find.byType(LoadingIndicator),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<AppButton>(deleteButtonFinder).onPressed,
            isNull,
          );
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'add CourseScheduleMutationCreateRequested when initial is null '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester);

          await tester.enterText(nameFieldFinder, 'Praktikum Pemrograman');
          await selectCohort(tester);
          await selectCourse(tester);
          await selectLecturer(tester);
          await selectRoom(tester);
          final testDate = DateTime(2025, 9, 8);
          await selectDate(tester, testDate);
          await tester.enterText(timeFieldFinder, '08:00');
          await tester.enterText(
            find.descendant(
              of: durationFieldFinder,
              matching: find.byType(TextFormField),
            ),
            '100',
          );

          await tester.ensureVisible(saveButtonFinder);
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => courseScheduleMutationBlocMock.add(
              CourseScheduleMutationCreateRequested(
                academicYearId: 'year_1',
                termId: 'term_1',
                programId: 'program_1',
                name: 'Praktikum Pemrograman',
                start: DateTime(2025, 9, 8, 8),
                duration: const Duration(minutes: 100),
                cohortId: cohortsMock.first.id,
                courseId: coursesMock.first.id,
                lecturerId: lecturersMock.first.id,
                roomId: roomsMock.first.id,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CourseScheduleMutationUpdateRequested when initial is provided '
        'and save valid fields',
        (tester) async {
          await pumpWidget(tester, initial: schedule);

          await tester.enterText(nameFieldFinder, 'Updated Schedule');
          await tester.ensureVisible(saveButtonFinder);
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          verify(
            () => courseScheduleMutationBlocMock.add(
              CourseScheduleMutationUpdateRequested(
                courseSchedule: schedule,
                academicYearId: schedule.academicYearId,
                termId: schedule.termId,
                programId: schedule.programId,
                name: 'Updated Schedule',
                start: schedule.start,
                duration: schedule.duration,
                cohortId: schedule.cohortId,
                courseId: schedule.courseId,
                lecturerId: schedule.lecturerId,
                roomId: schedule.roomId,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'add CourseScheduleMutationDeleteRequested when delete button pressed',
        (tester) async {
          await pumpWidget(tester, initial: schedule);

          await tester.ensureVisible(deleteButtonFinder);
          await tester.tap(deleteButtonFinder);
          await tester.pumpAndSettle();
          // Confirm on dialog
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          verify(
            () => courseScheduleMutationBlocMock.add(
              CourseScheduleMutationDeleteRequested(
                courseSchedule: schedule,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets('not clear fields when update success', (tester) async {
        final controller =
            StreamController<CourseScheduleMutationState>.broadcast();
        when(() => courseScheduleMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester, initial: schedule);

        await tester.enterText(nameFieldFinder, 'Updated Schedule');
        await tester.pumpAndSettle();

        expect(find.text('Updated Schedule'), findsOneWidget);

        controller.add(
          CourseScheduleMutationState(
            notice: CourseScheduleUpdatedNotice(
              before: schedule,
              after: schedule,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Updated Schedule'), findsOneWidget);
      });

      testWidgets('clear all fields when create success', (tester) async {
        final controller =
            StreamController<CourseScheduleMutationState>.broadcast();
        when(() => courseScheduleMutationBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);

        await tester.enterText(nameFieldFinder, 'New Schedule');
        await selectCohort(tester);
        await selectCourse(tester);
        await selectLecturer(tester);
        await selectRoom(tester);
        await selectDate(tester, DateTime(2025, 9, 8));
        await tester.enterText(timeFieldFinder, '08:00');
        await tester.enterText(
          find.descendant(
            of: durationFieldFinder,
            matching: find.byType(TextFormField),
          ),
          '100',
        );
        await tester.pumpAndSettle();

        expect(find.text('New Schedule'), findsOneWidget);
        expect(find.text(cohortsMock.first.name), findsOneWidget);

        controller.add(
          CourseScheduleMutationState(
            notice: CourseScheduleCreatedNotice(schedule),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('New Schedule'), findsNothing);
        expect(find.text(cohortsMock.first.name), findsNothing);
      });

      testWidgets(
        'shows success dialog with correct title and message when create '
        'success',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleCreatedNotice(schedule),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Jadwal kuliah berhasil disimpan'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Jadwal kuliah dengan nama "${schedule.name}" berhasil disimpan',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message when update '
        'success',
        (tester) async {
          final updated = CourseSchedule(
            id: schedule.id,
            academicYearId: schedule.academicYearId,
            termId: schedule.termId,
            name: 'Updated Schedule',
            start: schedule.start,
            duration: schedule.duration,
            cohortId: schedule.cohortId,
            courseId: schedule.courseId,
            programId: schedule.programId,
            lecturerId: schedule.lecturerId,
            roomId: schedule.roomId,
          );
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleUpdatedNotice(
                before: schedule,
                after: updated,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Jadwal kuliah "${schedule.name}" berhasil diperbarui'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Jadwal kuliah "${schedule.name}" berhasil diperbarui '
              'dengan nama "${updated.name}"',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when create failed',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleMutationFailedNotice(
                type: CourseScheduleMutationType.create,
                exception: AppException.test(),
                courseSchedule: null,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menyimpan jadwal kuliah baru'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when update failed',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleMutationFailedNotice(
                type: CourseScheduleMutationType.update,
                exception: AppException.test(),
                courseSchedule: schedule,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal memperbarui jadwal kuliah'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows success dialog with correct title and message '
        'when delete success',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);
          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleDeletedNotice(schedule),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Jadwal kuliah berhasil dihapus'),
            findsOneWidget,
          );
          expect(
            find.text(
              'Jadwal kuliah dengan nama "${schedule.name}" berhasil dihapus',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'calls onCourseScheduleDeleted when delete success',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          CourseSchedule? deletedSchedule;
          await pumpWidget(
            tester,
            onCourseScheduleDeleted: (deleted) {
              deletedSchedule = deleted;
            },
          );
          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleDeletedNotice(schedule),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          expect(deletedSchedule, schedule);
        },
      );

      testWidgets(
        'shows failed dialog with correct title and message when delete failed',
        (tester) async {
          final controller =
              StreamController<CourseScheduleMutationState>.broadcast();
          when(() => courseScheduleMutationBlocMock.stream)
              .thenAnswer((_) => controller.stream);

          await pumpWidget(tester);

          controller.add(
            CourseScheduleMutationState(
              notice: CourseScheduleMutationFailedNotice(
                type: CourseScheduleMutationType.delete,
                exception: AppException.test(),
                courseSchedule: schedule,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gagal menghapus jadwal kuliah'),
            findsOneWidget,
          );
          expect(
            find.text(AppExceptionCode.internal.message),
            findsOneWidget,
          );
        },
      );
    });
  });
}
