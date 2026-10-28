import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late AcademicYearDetailBloc academicYearDetailBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearDetailBlocMock = getIt<AcademicYearDetailBloc>();
    whenListen(
      academicYearDetailBlocMock,
      Stream.value(
        AcademicYearDetailLoaded(
          academicYear: academicYearMock,
          terms: academicTermsMock,
        ),
      ),
      initialState: AcademicYearDetailLoaded(
        academicYear: academicYearMock,
        terms: academicTermsMock,
      ),
    );
    when(academicYearDetailBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<AcademicCalendarMutationBloc>(),
      Stream.value(const AcademicCalendarMutationState()),
      initialState: const AcademicCalendarMutationState(),
    );
    when(getIt<AcademicCalendarMutationBloc>().close).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function(AcademicYear)? onAcademicYearDeleted,
  }) {
    return tester.pumpPageForTest(
      page: AcademicYearDetailPage(
        id: academicYearMock.id,
        onAcademicYearDeleted: onAcademicYearDeleted,
      ),
    );
  }

  tearDown(() {
    reset(academicYearDetailBlocMock);
  });

  group('AcademicYearDetailPage', () {
    group('Init', () {
      testWidgets(
        'add AcademicYearDetailSubscriptionRequested event to '
        'AcademicYearDetailBloc',
        (tester) async {
          await pumpWidget(tester);

          verify(
            () => academicYearDetailBlocMock.add(
              AcademicYearDetailSubscriptionRequested(id: academicYearMock.id),
            ),
          ).called(1);
        },
      );
    });

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Detail Tahun Akademik'), findsOneWidget);
      });

      testWidgets('provides AcademicYearDetailBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<AcademicYearDetailBloc>),
          findsOneWidget,
        );
      });

      testWidgets('provides AcademicCalendarMutationBloc', (tester) async {
        await pumpWidget(tester);

        expect(
          find.byType(BlocProvider<AcademicCalendarMutationBloc>),
          findsOneWidget,
        );
      });

      testWidgets('shows AcademicYearDetail', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(AcademicYearDetail), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'add AcademicYearDetailSubscriptionRequested event '
        'when retry button on AcademicYearDetail is pressed',
        (tester) async {
          await pumpWidget(tester);

          final detailFinder = find.byType(AcademicYearDetail);
          expect(detailFinder, findsOneWidget);
          final widget = tester.widget<AcademicYearDetail>(detailFinder);
          widget.onRetryPressed!();

          verify(
            () => academicYearDetailBlocMock.add(
              AcademicYearDetailSubscriptionRequested(id: academicYearMock.id),
            ),
          ).called(2);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onAcademicYearDeleted when AcademicYearDetail fires callback',
        (tester) async {
          AcademicYear? year;

          await pumpWidget(
            tester,
            onAcademicYearDeleted: (v) {
              year = v;
            },
          );

          final widget = tester.widget<AcademicYearDetail>(
            find.byType(AcademicYearDetail),
          );
          widget.onAcademicYearDeleted!(academicYearMock);

          expect(year, academicYearMock);
        },
      );
    });
  });
}
