import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late AcademicYearsBloc academicYearsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearsBlocMock = getIt<AcademicYearsBloc>();
    whenListen(
      academicYearsBlocMock,
      Stream.value(AcademicYearsLoaded(academicYearsMock)),
      initialState: AcademicYearsLoaded(academicYearsMock),
    );
    when(academicYearsBlocMock.close).thenAnswer((_) async {});

    whenListen(
      getIt<AcademicCalendarMutationBloc>(),
      Stream.value(const AcademicCalendarMutationState()),
      initialState: const AcademicCalendarMutationState(),
    );
    when(getIt<AcademicCalendarMutationBloc>().close).thenAnswer((_) async {});

    whenListen(
      getIt<AcademicYearDetailBloc>(),
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
    when(getIt<AcademicYearDetailBloc>().close).thenAnswer((_) async {});
  });

  tearDown(() {
    reset(academicYearsBlocMock);
    reset(getIt<AcademicCalendarMutationBloc>());
    reset(getIt<AcademicYearDetailBloc>());
  });

  Future<void> pumpWidget(WidgetTester tester, {Size? phoneSize}) {
    return tester.pumpPageForTest(
      path: '/academic-calendar',
      page: const AcademicYearsListPage(),
      phoneSize: phoneSize,
      childRoutes: [
        GoRoute(
          path: 'create',
          builder: (_, _) => const CreateAcademicYearPage(),
        ),
        GoRoute(
          path: 'create-compact',
          builder: (_, _) => const CreateAcademicYearPage(),
        ),
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return AcademicYearDetailPage(id: id);
          },
        ),
        GoRoute(
          path: 'compact/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return AcademicYearDetailPage(id: id);
          },
        ),
      ],
    );
  }

  group('AcademicYearsListPage', () {
    Future<void> createButtonPressed(WidgetTester tester) async {
      final widget = tester.widget<AcademicYearsList>(
        find.byType(AcademicYearsList),
      );
      widget.onCreatePressed!();
      await tester.pumpAndSettle();
    }

    Future<void> yearPressed(WidgetTester tester) async {
      final widget = tester.widget<AcademicYearsList>(
        find.byType(AcademicYearsList),
      );
      widget.onPressed!(academicYearMock);
      await tester.pumpAndSettle();
    }

    group('Render', () {
      testWidgets('shows correct title', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Daftar Tahun Akademik'), findsOneWidget);
      });

      testWidgets('provides AcademicYearsBloc', (tester) async {
        await pumpWidget(tester);

        expect(find.byType(BlocProvider<AcademicYearsBloc>), findsOneWidget);
      });

      testWidgets(
        'shows AcademicYearsList in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          expect(find.byType(AcademicYearsList), findsOneWidget);
        },
      );

      testWidgets(
        'shows AcademicYearsList in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          expect(find.byType(AcademicYearsList), findsOneWidget);
        },
      );

      testWidgets(
        'shows AcademicYearsList and CreateAcademicYearPage in expanded screen '
        'when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows AcademicYearsList and CreateAcademicYearPage in large screen '
        'when create button is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows AcademicYearsList and AcademicYearDetailPage in expanded screen '
        'when a year is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows AcademicYearsList and AcademicYearDetailPage in large screen '
        'when a year is pressed',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'set selectedId on AcademicYearsList when a year is pressed in '
        'expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await yearPressed(tester);

          final widget = tester.widget<AcademicYearsList>(
            find.byType(AcademicYearsList),
          );
          expect(widget.selectedId, academicYearMock.id);
        },
      );

      testWidgets(
        'set selectedId on AcademicYearsList when a year is pressed in '
        'large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await yearPressed(tester);

          final widget = tester.widget<AcademicYearsList>(
            find.byType(AcademicYearsList),
          );
          expect(widget.selectedId, academicYearMock.id);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'go to create page when create button is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsNothing);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to create page when create button is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsNothing);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows create page when create button is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await createButtonPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(CreateAcademicYearPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a year is pressed in compact screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(450, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsNothing);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'go to detail page when a year is pressed in medium screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(650, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsNothing);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a year is pressed in expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(900, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );

      testWidgets(
        'shows detail page when a year is pressed in large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await yearPressed(tester);

          expect(find.byType(AcademicYearsList), findsOneWidget);
          expect(find.byType(AcademicYearDetailPage), findsOneWidget);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'hides AcademicYearDetailPage when it fires onAcademicYearDeleted in '
        'expanded screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(850, 800));

          await yearPressed(tester);

          final detailPageFinder = find.byType(AcademicYearDetailPage);
          expect(detailPageFinder, findsOneWidget);

          final widget = tester.widget<AcademicYearDetailPage>(
            detailPageFinder,
          );
          widget.onAcademicYearDeleted!(academicYearMock);
          await tester.pumpAndSettle();

          expect(detailPageFinder, findsNothing);
        },
      );

      testWidgets(
        'hides AcademicYearDetailPage when it fires onAcademicYearDeleted in '
        'large screen',
        (tester) async {
          await pumpWidget(tester, phoneSize: const Size(1250, 800));

          await yearPressed(tester);

          final detailPageFinder = find.byType(AcademicYearDetailPage);
          expect(detailPageFinder, findsOneWidget);

          final widget = tester.widget<AcademicYearDetailPage>(
            detailPageFinder,
          );
          widget.onAcademicYearDeleted!(academicYearMock);
          await tester.pumpAndSettle();

          expect(detailPageFinder, findsNothing);
        },
      );
    });
  });
}
