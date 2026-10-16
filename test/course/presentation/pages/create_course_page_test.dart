import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';

void main() {
  group('CreateCoursePage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final courseMutationBlocMock = getIt<CourseMutationBloc>();
      whenListen(
        courseMutationBlocMock,
        Stream.value(const CourseMutationState()),
        initialState: const CourseMutationState(),
      );
      when(courseMutationBlocMock.close).thenAnswer((_) async {});

      final programsBlocMock = getIt<ProgramsBloc>();
      whenListen(
        programsBlocMock,
        Stream.value(ProgramsLoaded(programsUIMock)),
        initialState: ProgramsLoaded(programsUIMock),
      );
      when(programsBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateCoursePage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Mata Kuliah Baru'), findsOneWidget);
      });

      testWidgets('shows CourseForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CourseForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<CourseMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<CourseMutationBloc>),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BlocProvider<ProgramsBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<ProgramsBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
