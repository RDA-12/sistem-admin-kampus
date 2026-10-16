// ignore_for_file: avoid_redundant_argument_values need verbosity on test

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/di_mocks.dart';

void main() {
  const course = Course(
    id: 'id',
    programId: 'program_1',
    code: 'CS101',
    name: 'name',
    semester: 1,
    credit: 3,
  );
  late CreateCourseUseCase createCourseMock;
  late UpdateCourseUseCase updateCourseMock;
  late DeleteCourseUseCase deleteCourseMock;

  group('CourseMutationBloc', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      createCourseMock = getIt<CreateCourseUseCase>();
      updateCourseMock = getIt<UpdateCourseUseCase>();
      deleteCourseMock = getIt<DeleteCourseUseCase>();
    });

    CourseMutationBloc buildBloc() {
      return CourseMutationBloc(
        createCourse: createCourseMock,
        updateCourse: updateCourseMock,
        deleteCourse: deleteCourseMock,
      );
    }

    test('has correct initial state', () {
      final bloc = buildBloc();

      expect(bloc.state, const CourseMutationState());
    });

    group('CourseMutationCreateRequested', () {
      const params = CreateCourseParams(
        programId: 'program_1',
        code: 'CS101',
        name: 'name',
        semester: 1,
        credit: 3,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => createCourseMock(params))
            .thenAnswer((_) async => AppResult.success(course));
      });

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [isCreating true, created notice and isCreating false] '
        'when CourseMutationCreateRequested is added '
        'and CreateCourseUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseMutationCreateRequested(
            programId: params.programId,
            code: params.code,
            name: params.name,
            semester: params.semester,
            credit: params.credit,
          ),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(isCreating: true),
          const CourseMutationState(
            isCreating: false,
            notice: CourseCreatedNotice(course),
          ),
        ],
        verify: (_) {
          verify(() => createCourseMock(params)).called(1);
        },
      );

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [isCreating true, failure notice and isCreating false] '
        'when CourseMutationCreateRequested is added '
        'and CreateCourseUseCase fails',
        setUp: () {
          when(() => createCourseMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          CourseMutationCreateRequested(
            programId: params.programId,
            code: params.code,
            name: params.name,
            semester: params.semester,
            credit: params.credit,
          ),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(isCreating: true),
          CourseMutationState(
            isCreating: false,
            notice: CourseMutationFailedNotice(
              type: CourseMutationType.create,
              exception: AppException.test(),
              course: null,
            ),
          ),
        ],
        verify: (_) {
          verify(() => createCourseMock(params)).called(1);
        },
      );
    });

    group('CourseMutationUpdateRequested', () {
      const updatedCourse = Course(
        id: 'id',
        programId: 'program_1',
        code: 'CS102',
        name: 'updated',
        semester: 2,
        credit: 4,
      );
      const params = UpdateCourseParams(
        course,
        code: 'CS102',
        name: 'updated',
        semester: 2,
        credit: 4,
      );

      setUpAll(() {
        registerFallbackValue(params);
      });

      setUp(() {
        when(() => updateCourseMock(params))
            .thenAnswer((_) async => AppResult.success(updatedCourse));
      });

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [updatingIds with id, updated notice and empty updatingIds] '
        'when CourseMutationUpdateRequested is added '
        'and UpdateCourseUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CourseMutationUpdateRequested(
            course: course,
            code: 'CS102',
            name: 'updated',
            semester: 2,
            credit: 4,
          ),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(updatingIds: {'id'}),
          const CourseMutationState(
            updatingIds: {},
            notice: CourseUpdatedNotice(
              before: course,
              after: updatedCourse,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateCourseMock(params)).called(1);
        },
      );

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [updatingIds with id, failure notice and empty updatingIds] '
        'when CourseMutationUpdateRequested is added '
        'and UpdateCourseUseCase fails',
        setUp: () {
          when(() => updateCourseMock(params))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CourseMutationUpdateRequested(
            course: course,
            code: 'CS102',
            name: 'updated',
            semester: 2,
            credit: 4,
          ),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(updatingIds: {'id'}),
          CourseMutationState(
            updatingIds: const {},
            notice: CourseMutationFailedNotice(
              type: CourseMutationType.update,
              exception: AppException.test(),
              course: course,
            ),
          ),
        ],
        verify: (_) {
          verify(() => updateCourseMock(params)).called(1);
        },
      );
    });

    group('CourseMutationDeleteRequested', () {
      setUpAll(() {
        registerFallbackValue(course);
      });

      setUp(() {
        when(() => deleteCourseMock(course))
            .thenAnswer((_) async => AppResult.success(null));
      });

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [deletingIds with id, deleted notice and empty deletingIds] '
        'when CourseMutationDeleteRequested is added '
        'and DeleteCourseUseCase success',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CourseMutationDeleteRequested(course: course),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(deletingIds: {'id'}),
          const CourseMutationState(
            deletingIds: {},
            notice: CourseDeletedNotice(course),
          ),
        ],
        verify: (_) {
          verify(() => deleteCourseMock(course)).called(1);
        },
      );

      blocTest<CourseMutationBloc, CourseMutationState>(
        'emits [deletingIds with id, failure notice and empty deletingIds] '
        'when CourseMutationDeleteRequested is added '
        'and DeleteCourseUseCase fails',
        setUp: () {
          when(() => deleteCourseMock(course))
              .thenAnswer((_) async => AppResult.failure(AppException.test()));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const CourseMutationDeleteRequested(course: course),
        ),
        expect: () => <CourseMutationState>[
          const CourseMutationState(deletingIds: {'id'}),
          CourseMutationState(
            deletingIds: const {},
            notice: CourseMutationFailedNotice(
              type: CourseMutationType.delete,
              exception: AppException.test(),
              course: course,
            ),
          ),
        ],
        verify: (_) {
          verify(() => deleteCourseMock(course)).called(1);
        },
      );
    });
  });
}
