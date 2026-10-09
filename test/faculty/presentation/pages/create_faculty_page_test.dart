import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  group('CreateFacultyPage', () {
    setUpAll(initializeMockDependencies);

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateFacultyPage(),
      );
    }

    group('Render', () {
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
