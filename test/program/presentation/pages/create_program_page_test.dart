import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  group('CreateProgramPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final programMutationBlocMock = getIt<ProgramMutationBloc>();
      whenListen(
        programMutationBlocMock,
        Stream.value(const ProgramMutationState()),
        initialState: const ProgramMutationState(),
      );
      when(programMutationBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateProgramPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Program Studi Baru'), findsOneWidget);
      });

      testWidgets('shows ProgramForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(ProgramForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<ProgramMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<ProgramMutationBloc>),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'provides BlocProvider<FacultiesBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<FacultiesBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
