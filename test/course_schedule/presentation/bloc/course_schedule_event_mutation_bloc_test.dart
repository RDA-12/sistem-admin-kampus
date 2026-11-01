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
  late CreateCourseScheduleEventUseCase createUseCaseMock;
  late UpdateCourseScheduleEventUseCase updateUseCaseMock;
  late DeleteCourseScheduleEventUseCase deleteUseCaseMock;

  group('CourseScheduleEventMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createUseCaseMock = getIt<CreateCourseScheduleEventUseCase>();
      updateUseCaseMock = getIt<UpdateCourseScheduleEventUseCase>();
      deleteUseCaseMock = getIt<DeleteCourseScheduleEventUseCase>();
    });

    CourseScheduleEventMutationBloc buildBloc() {
      return CourseScheduleEventMutationBloc(
        createCourseScheduleEvent: createUseCaseMock,
        updateCourseScheduleEvent: updateUseCaseMock,
        deleteCourseScheduleEvent: deleteUseCaseMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CourseScheduleEventMutationState());
    });

    group('CourseScheduleEventMutationCreateRequested', () {
      final params = CreateCourseScheduleEventParams(
        academicYearId: event.academicYearId,
        name: event.name,
        start: event.start,
        end: event.end,
        courseDetail: event.courseDetail,
        recurrence: event.recurrence,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createUseCaseMock(params))
            .thenAnswer((_) async => AppResult.success(event));
      });

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [isCreating true, created notice and isCreating false] '
        'when CourseScheduleEventMutationCreateRequested is added '
        'and CreateCourseScheduleEventUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            start: params.start,
            end: params.end,
            courseDetail: params.courseDetail,
            recurrence: params.recurrence,
          ),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          const CourseScheduleEventMutationState(isCreating: true),
          CourseScheduleEventMutationState(
            isCreating: false,
            notice: CourseScheduleEventCreatedNotice(event),
          ),
        ],
        verify: (_) {
          verify(() => createUseCaseMock(params)).called(1);
        },
      );

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [isCreating true, failure notice and isCreating false] '
        'when CourseScheduleEventMutationCreateRequested is added '
        'and CreateCourseScheduleEventUseCase fails',
        setUp: () {
          when(() => createUseCaseMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationCreateRequested(
            academicYearId: params.academicYearId,
            name: params.name,
            start: params.start,
            end: params.end,
            courseDetail: params.courseDetail,
            recurrence: params.recurrence,
          ),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          const CourseScheduleEventMutationState(isCreating: true),
          CourseScheduleEventMutationState(
            isCreating: false,
            notice: CourseScheduleEventMutationFailedNotice(
              type: CourseScheduleEventMutationType.create,
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

    group('CourseScheduleEventMutationUpdateRequested', () {
      final updatedEvent = CourseScheduleEvent(
        id: event.id,
        academicYearId: event.academicYearId,
        name: 'New Schedule Name',
        start: event.start,
        end: event.end,
        courseDetail: event.courseDetail,
        recurrence: event.recurrence,
      );
      final params = UpdateCourseScheduleEventParams(
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

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when CourseScheduleEventMutationUpdateRequested is added '
        'and UpdateCourseScheduleEventUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationUpdateRequested(
            event: event,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          CourseScheduleEventMutationState(updatingIds: {event.id}),
          CourseScheduleEventMutationState(
            updatingIds: const {},
            notice: CourseScheduleEventUpdatedNotice(
              before: event,
              after: updatedEvent,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateUseCaseMock(params)).called(1);
        },
      );

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when CourseScheduleEventMutationUpdateRequested is added '
        'and UpdateCourseScheduleEventUseCase fails',
        setUp: () {
          when(() => updateUseCaseMock(params)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationUpdateRequested(
            event: event,
            name: 'New Schedule Name',
          ),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          CourseScheduleEventMutationState(updatingIds: {event.id}),
          CourseScheduleEventMutationState(
            updatingIds: const {},
            notice: CourseScheduleEventMutationFailedNotice(
              type: CourseScheduleEventMutationType.update,
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

    group('CourseScheduleEventMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(event);
      });

      setUp(() {
        when(() => deleteUseCaseMock(event))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when CourseScheduleEventMutationDeleteRequested is added '
        'and DeleteCourseScheduleEventUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationDeleteRequested(event: event),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          CourseScheduleEventMutationState(deletingIds: {event.id}),
          CourseScheduleEventMutationState(
            deletingIds: const {},
            notice: CourseScheduleEventDeletedNotice(event),
          ),
        ],
        verify: (_) {
          verify(() => deleteUseCaseMock(event)).called(1);
        },
      );

      blocTest<
        CourseScheduleEventMutationBloc,
        CourseScheduleEventMutationState
      >(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when CourseScheduleEventMutationDeleteRequested is added '
        'and DeleteCourseScheduleEventUseCase fails',
        setUp: () {
          when(() => deleteUseCaseMock(event)).thenAnswer(
            (_) async => AppResult.failure(AppException.test()),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseScheduleEventMutationDeleteRequested(event: event),
        ),
        expect: () => <CourseScheduleEventMutationState>[
          CourseScheduleEventMutationState(deletingIds: {event.id}),
          CourseScheduleEventMutationState(
            deletingIds: const {},
            notice: CourseScheduleEventMutationFailedNotice(
              type: CourseScheduleEventMutationType.delete,
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
