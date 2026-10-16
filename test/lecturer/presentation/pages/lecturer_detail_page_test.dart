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
import '../../domain/mocks.dart';

void main() {
  late LecturerDetailBloc lecturerDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturerDetailBlocMock = getIt<LecturerDetailBloc>();
    whenListen(
      lecturerDetailBlocMock,
      Stream.value(LecturerDetailLoaded(lecturer: lecturerUIMock)),
      initialState: LecturerDetailLoaded(lecturer: lecturerUIMock),
    );
    when(lecturerDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<LecturerMutationBloc>(),
      Stream.value(const LecturerMutationState()),
      initialState: const LecturerMutationState(),
    );
    when(getIt<LecturerMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<ProgramsBloc>(),
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );
    when(getIt<ProgramsBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(Lecturer)? onLecturerDeleted,
  }) {
    return tester.pumpPageForTest(
      page: LecturerDetailPage(
        id: lecturerMock.id,
        onLecturerDeleted: onLecturerDeleted,
      ),
    );
  }

  tearDown(() {
    reset(lecturerDetailBlocMock);
  });

  group('LecturerDetailPage', () {
    group('Init', () {
      testWidgets(
        'add LecturerDetailSubscriptionRequested event to LecturerDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => lecturerDetailBlocMock.add(
              LecturerDetailSubscriptionRequested(id: lecturerMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Dosen'), findsOneWidget);
      });

      testWidgets('provides LecturerDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<LecturerDetailBloc>), findsOneWidget);
      });

      testWidgets('provides LecturerMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<LecturerMutationBloc>), findsOneWidget);
      });

      testWidgets('provides ProgramsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<ProgramsBloc>), findsOneWidget);
      });

      testWidgets('shows LecturerDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(LecturerDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add LecturerDetailSubscriptionRequested event '
        'when retry button on LecturerDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final lecturerDetailFinder = find.byType(LecturerDetail);
          expect(lecturerDetailFinder, findsOneWidget);
          final widget = tester.widget<LecturerDetail>(lecturerDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => lecturerDetailBlocMock.add(
              LecturerDetailSubscriptionRequested(id: lecturerMock.id),
            ),
          ).called(2);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onLecturerDeleted when LecturerDetail fires onLecturerDeleted',
        (tester) async {
          Lecturer? lecturer;

          await pumpWidget(
            tester,
            onLecturerDeleted: (v) {
              lecturer = v;
            },
          );

          final widget = tester.widget<LecturerDetail>(
            find.byType(LecturerDetail),
          );
          widget.onLecturerDeleted!(lecturerMock);

          expect(lecturer, lecturerMock);
        },
      );
    });
  });
}
