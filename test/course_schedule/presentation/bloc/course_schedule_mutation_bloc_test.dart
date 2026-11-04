// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course_schedule/course_schedule.dart';

import '../../../common/di_mocks.dart';
import '../../domain/mocks.dart';

void main() {
  final schedule = courseScheduleMock;
  late CreateCourseScheduleUseCase createUseCaseMock;
  late UpdateCourseScheduleUseCase updateUseCaseMock;
  late DeleteCourseScheduleUseCase deleteUseCaseMock;

  group('CourseScheduleMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createUseCaseMock = getIt<CreateCourseScheduleUseCase>();
      updateUseCaseMock = getIt<UpdateCourseScheduleUseCase>();
      deleteUseCaseMock = getIt<DeleteCourseScheduleUseCase>();
    });

    CourseScheduleMutationBloc buildBloc() {
      return CourseScheduleMutationBloc(
        createCourseSchedule: createUseCaseMock,
        updateCourseSchedule: updateUseCaseMock,
        deleteCourseSchedule: deleteUseCaseMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CourseScheduleMutationState());
    });

    group('CourseScheduleMutationCreateRequested', () {
      final params = CreateCourseScheduleParams(
        academicYearId: schedule.academicYearId,
        termId: schedule.termId,
        programId: schedule.programId,
        name: schedule.name,
        start: schedule.start,
        duration: schedule.duration,
        cohortId: schedule.cohortId,
        courseId: schedule.courseId,
        lecturerId: schedule.lecturerId,
        roomId: schedule.roomId,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createUseCaseMock(params))
            .thenAnswer((_) async => AppResult.success(schedule));
      });

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when CourseScheduleMutationCreateRequested is added '
        'and CreateCourseScheduleUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationCreateRequested(
            academicYearId: params.academicYearId,
            termId: params.termId,
            programId: params.programId,
            name: params.name,
            start: params.start,
            duration: params.duration,
            cohortId: params.cohortId,
            courseId: params.courseId,
            lecturerId: params.lecturerId,
            roomId: params.roomId,
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          const CourseScheduleMutationState(isCreating: true),
          CourseScheduleMutationState(
            isCreating: false,
            notice: CourseScheduleCreatedNotice(schedule),
          ),
        ],
        verify: (_) {
          verify(() => createUseCaseMock(params)).called(1);
        },
      );

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when CourseScheduleMutationCreateRequested is added '
        'and CreateCourseScheduleUseCase fails',
        setUp: () {
          when(() => createUseCaseMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationCreateRequested(
            academicYearId: params.academicYearId,
            termId: params.termId,
            programId: params.programId,
            name: params.name,
            start: params.start,
            duration: params.duration,
            cohortId: params.cohortId,
            courseId: params.courseId,
            lecturerId: params.lecturerId,
            roomId: params.roomId,
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          const CourseScheduleMutationState(isCreating: true),
          CourseScheduleMutationState(
            isCreating: false,
            notice: CourseScheduleMutationFailedNotice(
              type: CourseScheduleMutationType.create,
              exception: AppException.test(),
              courseSchedule: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createUseCaseMock(params)).called(1);
        },
      );
    });

    group('CourseScheduleMutationUpdateRequested', () {
      final updatedSchedule = CourseSchedule(
        id: schedule.id,
        academicYearId: schedule.academicYearId,
        termId: schedule.termId,
        programId: schedule.programId,
        name: 'New Schedule Name',
        start: schedule.start,
        duration: schedule.duration,
        cohortId: schedule.cohortId,
        courseId: schedule.courseId,
        lecturerId: schedule.lecturerId,
        roomId: schedule.roomId,
      );
      final params = UpdateCourseScheduleParams(
        schedule,
        name: 'New Schedule Name',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateUseCaseMock(params))
            .thenAnswer((_) async => AppResult.success(updatedSchedule));
      });

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when CourseScheduleMutationUpdateRequested is added '
        'and UpdateCourseScheduleUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationUpdateRequested(
            courseSchedule: schedule,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(updatingIds: {schedule.id}),
          CourseScheduleMutationState(
            updatingIds: const {},
            notice: CourseScheduleUpdatedNotice(
              before: schedule,
              after: updatedSchedule,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateUseCaseMock(params)).called(1);
        },
      );

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when CourseScheduleMutationUpdateRequested is added '
        'and UpdateCourseScheduleUseCase fails',
        setUp: () {
          when(() => updateUseCaseMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationUpdateRequested(
            courseSchedule: schedule,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(updatingIds: {schedule.id}),
          CourseScheduleMutationState(
            updatingIds: const {},
            notice: CourseScheduleMutationFailedNotice(
              type: CourseScheduleMutationType.update,
              exception: AppException.test(),
              courseSchedule: schedule,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateUseCaseMock(params)).called(1);
        },
      );
    });

    group('CourseScheduleMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(schedule);
      });

      setUp(() {
        when(() => deleteUseCaseMock(schedule))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when CourseScheduleMutationDeleteRequested is added '
        'and DeleteCourseScheduleUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationDeleteRequested(courseSchedule: schedule),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(deletingIds: {schedule.id}),
          CourseScheduleMutationState(
            deletingIds: const {},
            notice: CourseScheduleDeletedNotice(schedule),
          ),
        ],
        verify: (_) {
          verify(() => deleteUseCaseMock(schedule)).called(1);
        },
      );

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when CourseScheduleMutationDeleteRequested is added '
        'and DeleteCourseScheduleUseCase fails',
        setUp: () {
          when(() => deleteUseCaseMock(schedule)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationDeleteRequested(courseSchedule: schedule),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(deletingIds: {schedule.id}),
          CourseScheduleMutationState(
            deletingIds: const {},
            notice: CourseScheduleMutationFailedNotice(
              type: CourseScheduleMutationType.delete,
              exception: AppException.test(),
              courseSchedule: schedule,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteUseCaseMock(schedule)).called(1);
        },
      );
    });
  });
}
