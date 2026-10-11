import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  group('CreateFacultyPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final facultyMutationBlocMock = getIt<FacultyMutationBloc>();
      whenListen(
        facultyMutationBlocMock,
        Stream.value(const FacultyMutationState()),
        initialState: const FacultyMutationState(),
      );
      when(facultyMutationBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateFacultyPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Fakultas Baru'), findsOneWidget);
      });

      testWidgets('shows FacultyForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(FacultyForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<FacultyMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<FacultyMutationBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
