import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  group('CreateCohortPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final cohortMutationBlocMock = getIt<CohortMutationBloc>();
      whenListen(
        cohortMutationBlocMock,
        Stream.value(const CohortMutationState()),
        initialState: const CohortMutationState(),
      );
      when(cohortMutationBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateCohortPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Angkatan Baru'), findsOneWidget);
      });

      testWidgets('shows CohortForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(CohortForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<CohortMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<CohortMutationBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
