import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';

void main() {
  group('CreateLecturerPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final lecturerMutationBlocMock = getIt<LecturerMutationBloc>();
      whenListen(
        lecturerMutationBlocMock,
        Stream.value(const LecturerMutationState()),
        initialState: const LecturerMutationState(),
      );
      when(lecturerMutationBlocMock.close).thenAnswer((_) async {});

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
        page: const CreateLecturerPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Dosen Baru'), findsOneWidget);
      });

      testWidgets('shows LecturerForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(LecturerForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<LecturerMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<LecturerMutationBloc>),
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
