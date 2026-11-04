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
  final event = courseScheduleEventMock;
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
        academicYearId: event.academicYearId,
        termId: event.termId,
        programId: event.programId,
        name: event.name,
        start: event.start,
        durationInMinutes: event.durationInMinutes,
        cohortId: event.cohortId,
        courseId: event.courseId,
        lecturerId: event.lecturerId,
        roomId: event.roomId,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createUseCaseMock(params))
            .thenAnswer((_) async => AppResult.success(event));
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
            durationInMinutes: params.durationInMinutes,
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
            notice: CourseScheduleCreatedNotice(event),
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
            durationInMinutes: params.durationInMinutes,
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
              event: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createUseCaseMock(params)).called(1);
        },
      );
    });

    group('CourseScheduleMutationUpdateRequested', () {
      final updatedEvent = CourseSchedule(
        id: event.id,
        academicYearId: event.academicYearId,
        termId: event.termId,
        programId: event.programId,
        name: 'New Schedule Name',
        start: event.start,
        durationInMinutes: event.durationInMinutes,
        cohortId: event.cohortId,
        courseId: event.courseId,
        lecturerId: event.lecturerId,
        roomId: event.roomId,
      );
      final params = UpdateCourseScheduleParams(
        event,
        name: 'New Schedule Name',
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateUseCaseMock(params))
            .thenAnswer((_) async => AppResult.success(updatedEvent));
      });

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when CourseScheduleMutationUpdateRequested is added '
        'and UpdateCourseScheduleUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationUpdateRequested(
            event: event,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(updatingIds: {event.id}),
          CourseScheduleMutationState(
            updatingIds: const {},
            notice: CourseScheduleUpdatedNotice(
              before: event,
              after: updatedEvent,
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
            event: event,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(updatingIds: {event.id}),
          CourseScheduleMutationState(
            updatingIds: const {},
            notice: CourseScheduleMutationFailedNotice(
              type: CourseScheduleMutationType.update,
              exception: AppException.test(),
              event: event,
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
        registerFallbackValue(event);
      });

      setUp(() {
        when(() => deleteUseCaseMock(event))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when CourseScheduleMutationDeleteRequested is added '
        'and DeleteCourseScheduleUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationDeleteRequested(event: event),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(deletingIds: {event.id}),
          CourseScheduleMutationState(
            deletingIds: const {},
            notice: CourseScheduleDeletedNotice(event),
          ),
        ],
        verify: (_) {
          verify(() => deleteUseCaseMock(event)).called(1);
        },
      );

      blocTest<CourseScheduleMutationBloc, CourseScheduleMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when CourseScheduleMutationDeleteRequested is added '
        'and DeleteCourseScheduleUseCase fails',
        setUp: () {
          when(() => deleteUseCaseMock(event)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleMutationDeleteRequested(event: event),
        ),
        expect: () => <CourseScheduleMutationState>[
          CourseScheduleMutationState(deletingIds: {event.id}),
          CourseScheduleMutationState(
            deletingIds: const {},
            notice: CourseScheduleMutationFailedNotice(
              type: CourseScheduleMutationType.delete,
              exception: AppException.test(),
              event: event,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteUseCaseMock(event)).called(1);
        },
      );
    });
  });
}
