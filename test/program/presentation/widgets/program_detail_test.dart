import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../course/domain/mocks.dart';
import '../../../faculty/domain/mocks.dart';
import '../../../lecturer/domain/mocks.dart';
import '../../domain/mocks.dart';

void main() {
  late ProgramDetailBloc programDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programDetailBlocMock = getIt<ProgramDetailBloc>();
    whenListen(
      programDetailBlocMock,
      Stream.value(
        ProgramDetailLoaded(
          program: programUIMock,
          lecturers: lecturersMock,
          courses: coursesMock,
        ),
      ),
      initialState: ProgramDetailLoaded(
        program: programUIMock,
        lecturers: lecturersMock,
        courses: coursesMock,
      ),
    );

    whenListen(
      getIt<ProgramMutationBloc>(),
      Stream.value(const ProgramMutationState()),
      initialState: const ProgramMutationState(),
    );

    whenListen(
      getIt<FacultiesBloc>(),
      Stream.value(FacultiesLoaded(facultiesMock)),
      initialState: FacultiesLoaded(facultiesMock),
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(Program)? onProgramDeleted,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return ProgramDetail(
          onRetryPressed: onRetryPressed,
          onProgramDeleted: onProgramDeleted,
        );
      },
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: programDetailBlocMock,
            ),
            BlocProvider.value(
              value: getIt<ProgramMutationBloc>(),
            ),
            BlocProvider.value(
              value: getIt<FacultiesBloc>(),
            ),
          ],
          child: child,
        );
      },
    );
  }

  group('ProgramDetail', () {
    group('Render', () {
      testWidgets(
        'shows ProgramForm with correct program '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(ProgramForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<ProgramForm>(finder);
          expect(widget.initial, programUIMock);
        },
      );

      testWidgets(
        'shows ProgramLecturersList with correct lecturers '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          expect(find.text('Daftar Dosen'), findsOneWidget);
          final finder = find.byType(ProgramLecturersList);
          expect(finder, findsOneWidget);
          final widget = tester.widget<ProgramLecturersList>(finder);
          expect(widget.lecturers, lecturersMock);
        },
      );

      testWidgets(
        'shows ProgramCoursesList with correct courses '
        'when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          await tester.drag(
            find.byType(ProgramDetail),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();

          expect(find.text('Daftar Mata Kuliah'), findsOneWidget);
          final finder = find.byType(ProgramCoursesList);
          expect(finder, findsOneWidget);
          final widget = tester.widget<ProgramCoursesList>(finder);
          expect(widget.courses, coursesMock);
        },
      );

      testWidgets(
        'shows LoadingIndicator when state is loading',
        (tester) async {
          whenListen(
            programDetailBlocMock,
            Stream.value(const LoadingProgramDetail()),
            initialState: const LoadingProgramDetail(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is failed',
        (tester) async {
          whenListen(
            programDetailBlocMock,
            Stream.value(
              ProgramDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: ProgramDetailLoadFailed(
              exception: AppException.test(),
            ),
          );

          await pumpWidget(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.title, 'Gagal mengambil data program studi');
          expect(widget.exception, AppException.test());
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onRetryPressed when state is failed '
        'and retry button is pressed',
        (tester) async {
          whenListen(
            programDetailBlocMock,
            Stream.value(
              ProgramDetailLoadFailed(exception: AppException.test()),
            ),
            initialState: ProgramDetailLoadFailed(
              exception: AppException.test(),
            ),
          );
          var pressed = false;
          await pumpWidget(
            tester,
            onRetryPressed: () {
              pressed = true;
            },
          );

          await tester.tap(
            find.descendant(
              of: find.byType(AppExceptionBox),
              matching: find.byType(AppButton),
            ),
          );

          expect(pressed, isTrue);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onProgramDeleted '
        'when ProgramDetail fires onProgramDeleted callback',
        (tester) async {
          Program? deleted;

          await pumpWidget(
            tester,
            onProgramDeleted: (v) {
              deleted = v;
            },
          );

          final finder = find.byType(ProgramForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<ProgramForm>(finder);
          widget.onProgramDeleted!(programUIMock);

          expect(deleted, programUIMock);
        },
      );
    });
  });
}
