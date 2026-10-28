import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';

void main() {
  group('CreateAcademicYearPage', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      final academicCalendarMutationBlocMock =
          getIt<AcademicCalendarMutationBloc>();
      whenListen(
        academicCalendarMutationBlocMock,
        Stream.value(const AcademicCalendarMutationState()),
        initialState: const AcademicCalendarMutationState(),
      );
      when(academicCalendarMutationBlocMock.close).thenAnswer((_) async {});
    });

    Future<void> pumpWidget(WidgetTester tester) {
      return tester.pumpPageForTest(
        page: const CreateAcademicYearPage(),
      );
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Buat Tahun Akademik Baru'), findsOneWidget);
      });

      testWidgets('shows AcademicCalendarForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(AcademicCalendarForm), findsOneWidget);
      });

      testWidgets('shows AcademicYearForm', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(AcademicYearForm), findsOneWidget);
      });

      testWidgets(
        'provides BlocProvider<AcademicCalendarMutationBloc>',
        (tester) async {
          await pumpWidget(tester);

          expect(
            find.byType(BlocProvider<AcademicCalendarMutationBloc>),
            findsOneWidget,
          );
        },
      );
    });
  });
}
