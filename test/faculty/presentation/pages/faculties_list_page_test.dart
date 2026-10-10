import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  late FacultiesBloc facultiesBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    facultiesBlocMock = getIt<FacultiesBloc>();
    whenListen(
      facultiesBlocMock,
      Stream.value(const FacultiesInitial()),
      initialState: const FacultiesInitial(),
    );
    when(facultiesBlocMock.close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(facultiesBlocMock);
  });

  Future<void> pumpWidget(WidgetTester tester) {
    return tester.pumpPageForTest(
      page: const FacultiesListPage(),
    );
  }

  group('FacultiesListPage', () {
    group('Render', () {
      testWidgets('provides FacultiesBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<FacultiesBloc>), findsOneWidget);
      });

      testWidgets('shows FacultiesList', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(FacultiesList), findsOneWidget);
      });
    });
  });
}
