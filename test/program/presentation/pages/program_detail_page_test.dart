import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late ProgramDetailBloc programDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programDetailBlocMock = getIt<ProgramDetailBloc>();
    whenListen(
      programDetailBlocMock,
      Stream.value(ProgramDetailLoaded(program: programUIMock)),
      initialState: ProgramDetailLoaded(program: programUIMock),
    );
    when(programDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramMutationBloc>(),
      Stream.value(const ProgramMutationState()),
      initialState: const ProgramMutationState(),
    );
    when(getIt<ProgramMutationBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Program)? onProgramDeleted,
  }) {
    return tester.pumpPageForTest(
      page: ProgramDetailPage(
        id: programMock.id,
        onProgramDeleted: onProgramDeleted,
      ),
    );
  }

  tearDown(() {
    reset(programDetailBlocMock);
  });

  group('ProgramDetailPage', () {
    group('Init', () {
      testWidgets(
        'add ProgramDetailSubscriptionRequested event to ProgramDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => programDetailBlocMock.add(
              ProgramDetailSubscriptionRequested(id: programMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Program Studi'), findsOneWidget);
      });

      testWidgets('provides ProgramDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<ProgramDetailBloc>), findsOneWidget);
      });

      testWidgets('provides ProgramMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<ProgramMutationBloc>), findsOneWidget);
      });

      testWidgets('provides FacultiesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultiesBloc>), findsOneWidget);
      });

      testWidgets('shows ProgramDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(ProgramDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add ProgramDetailSubscriptionRequested event '
        'when retry button on ProgramDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final programDetailFinder = find.byType(ProgramDetail);
          expect(programDetailFinder, findsOneWidget);
          final widget = tester.widget<ProgramDetail>(programDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => programDetailBlocMock.add(
              ProgramDetailSubscriptionRequested(id: programMock.id),
            ),
          ).called(2);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onProgramDeleted when ProgramDetail fires onProgramDeleted',
        (tester) async {
          Program? program;

          await pumpWidget(
            tester,
            onProgramDeleted: (v) {
              program = v;
            },
          );

          final widget = tester.widget<ProgramDetail>(
            find.byType(ProgramDetail),
          );
          widget.onProgramDeleted!(programMock);

          expect(program, programMock);
        },
      );
    });
  });
}
