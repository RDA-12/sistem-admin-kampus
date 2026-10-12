import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late FacultyDetailBloc facultyDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultyDetailBlocMock = getIt<FacultyDetailBloc>();
    whenListen(
      facultyDetailBlocMock,
      Stream.value(const FacultyDetailLoaded(faculty: facultyMock)),
      initialState: const FacultyDetailLoaded(faculty: facultyMock),
    );
    when(facultyDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<FacultyMutationBloc>(),
      Stream.value(const FacultyMutationState()),
      initialState: const FacultyMutationState(),
    );
    when(getIt<FacultyMutationBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(WidgetTester tester) {
    return tester.pumpPageForTest(
      page: FacultyDetailPage(id: facultyMock.id),
    );
  }

  tearDown(() {
    reset(facultyDetailBlocMock);
  });

  group('FacultyDetailPage', () {
    group('Init', () {
      testWidgets(
        'add FacultyDetailSubscriptionRequested event to FacultyDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => facultyDetailBlocMock.add(
              FacultyDetailSubscriptionRequested(id: facultyMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Fakultas'), findsOneWidget);
      });

      testWidgets('provides FacultyDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultyDetailBloc>), findsOneWidget);
      });

      testWidgets('provides FacultyMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultyMutationBloc>), findsOneWidget);
      });

      testWidgets('shows FacultyDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(FacultyDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add FacultyDetailSubscriptionRequested event '
        'when retry button on FacultyDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final facultyDetailFinder = find.byType(FacultyDetail);
          expect(facultyDetailFinder, findsOneWidget);
          final widget = tester.widget<FacultyDetail>(facultyDetailFinder);
          widget.onRetryPressed!();

          verify(
            () => facultyDetailBlocMock.add(
              FacultyDetailSubscriptionRequested(id: facultyMock.id),
            ),
          ).called(2); // Expect called 2, one on init
        },
      );
    });
  });
}
