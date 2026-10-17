import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  final year = academicYearMock;
  final terms = academicTermsMock;
  late AcademicYearDetailBloc academicYearDetailBlocMock;
  late AcademicYearMutationBloc academicYearMutationBlocMock;
  late AcademicTermMutationBloc academicTermMutationBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearDetailBlocMock = getIt<AcademicYearDetailBloc>();
    academicYearMutationBlocMock = getIt<AcademicYearMutationBloc>();
    academicTermMutationBlocMock = getIt<AcademicTermMutationBloc>();

    whenListen(
      academicYearDetailBlocMock,
      Stream.value(
        AcademicYearDetailLoaded(
          academicYear: year,
          terms: terms,
        ),
      ),
      initialState: AcademicYearDetailLoaded(
        academicYear: year,
        terms: terms,
      ),
    );

    whenListen(
      academicYearMutationBlocMock,
      Stream.value(const AcademicYearMutationState()),
      initialState: const AcademicYearMutationState(),
    );

    whenListen(
      academicTermMutationBlocMock,
      Stream.value(const AcademicTermMutationState()),
      initialState: const AcademicTermMutationState(),
    );
  });

  tearDown(() {
    reset(academicYearDetailBlocMock);
    reset(academicYearMutationBlocMock);
    reset(academicTermMutationBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onRetryPressed,
    void Function(AcademicYear)? onAcademicYearDeleted,
    void Function(AcademicTerm)? onTermPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) => AcademicYearDetail(
        onRetryPressed: onRetryPressed,
        onAcademicYearDeleted: onAcademicYearDeleted,
        onTermPressed: onTermPressed,
      ),
      providerBuilder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: academicYearDetailBlocMock),
            BlocProvider.value(value: academicYearMutationBlocMock),
            BlocProvider.value(value: academicTermMutationBlocMock),
          ],
          child: child,
        );
      },
    );
  }

  group('AcademicYearDetail', () {
    group('Render', () {
      testWidgets('shows loading indicator when state is loading', (
        tester,
      ) async {
        whenListen(
          academicYearDetailBlocMock,
          Stream.value(const LoadingAcademicYearDetail()),
          initialState: const LoadingAcademicYearDetail(),
        );

        await pumpWidget(tester);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AcademicYearForm and AcademicYearTerms when loaded',
        (tester) async {
          await pumpWidget(tester);

          expect(find.byType(AcademicYearForm), findsOneWidget);
          expect(find.byType(AcademicYearTerms), findsOneWidget);
        },
      );

      testWidgets('shows AppExceptionBox when failed', (tester) async {
        whenListen(
          academicYearDetailBlocMock,
          Stream.value(
            AcademicYearDetailLoadFailed(exception: AppException.test()),
          ),
          initialState: AcademicYearDetailLoadFailed(
            exception: AppException.test(),
          ),
        );

        await pumpWidget(tester);

        expect(find.byType(AppExceptionBox), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets('calls onRetryPressed when retry button is pressed', (
        tester,
      ) async {
        var retried = false;
        whenListen(
          academicYearDetailBlocMock,
          Stream.value(
            AcademicYearDetailLoadFailed(exception: AppException.test()),
          ),
          initialState: AcademicYearDetailLoadFailed(
            exception: AppException.test(),
          ),
        );

        await pumpWidget(
          tester,
          onRetryPressed: () {
            retried = true;
          },
        );

        final retryFinder = find.text('Coba lagi');
        await tester.tap(retryFinder);
        await tester.pumpAndSettle();

        expect(retried, isTrue);
      });

      testWidgets('calls onTermPressed when term tile is pressed', (
        tester,
      ) async {
        AcademicTerm? pressedTerm;
        await pumpWidget(
          tester,
          onTermPressed: (t) {
            pressedTerm = t;
          },
        );

        await tester.tap(find.text(terms.first.name));
        await tester.pumpAndSettle();

        expect(pressedTerm, equals(terms.first));
      });

      testWidgets(
        'shows create term dialog when add term button is pressed',
        (tester) async {
          await pumpWidget(tester);

          await tester.tap(find.text('Tambah'));
          await tester.pumpAndSettle();

          expect(find.text('Tambah Semester'), findsOneWidget);
          expect(find.byType(AcademicTermForm), findsOneWidget);
        },
      );

      testWidgets(
        'shows update term dialog when term tile is pressed '
        'and onTermPressed is null',
        (tester) async {
          await pumpWidget(tester);

          await tester.tap(find.text(terms.first.name));
          await tester.pumpAndSettle();

          expect(find.text('Ubah Semester'), findsOneWidget);
          expect(find.byType(AcademicTermForm), findsOneWidget);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onAcademicYearDeleted '
        'when AcademicYearForm fires onAcademicYearDeleted callback',
        (tester) async {
          AcademicYear? deleted;
          await pumpWidget(
            tester,
            onAcademicYearDeleted: (y) {
              deleted = y;
            },
          );

          final finder = find.byType(AcademicYearForm);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearForm>(finder);
          widget.onAcademicYearDeleted!(year);

          expect(deleted, year);
        },
      );

      testWidgets(
        'shows create term dialog '
        'when AcademicYearTerms fires onAddTermPressed callback',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onAddTermPressed!();
          await tester.pumpAndSettle();

          expect(find.text('Tambah Semester'), findsOneWidget);
          expect(find.byType(AcademicTermForm), findsOneWidget);
        },
      );

      testWidgets(
        'shows update term dialog '
        'when AcademicYearTerms fires onTermPressed callback '
        'and onTermPressed is not provided',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onTermPressed!(terms.first);
          await tester.pumpAndSettle();

          expect(find.text('Ubah Semester'), findsOneWidget);
          expect(find.byType(AcademicTermForm), findsOneWidget);
        },
      );

      testWidgets(
        'calls onTermPressed '
        'when AcademicYearTerms fires onTermPressed callback '
        'and onTermPressed is provided',
        (tester) async {
          AcademicTerm? pressedTerm;
          await pumpWidget(
            tester,
            onTermPressed: (t) {
              pressedTerm = t;
            },
          );

          final finder = find.byType(AcademicYearTerms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onTermPressed!(terms.first);
          await tester.pumpAndSettle();

          expect(pressedTerm, equals(terms.first));
          expect(find.byType(AcademicTermForm), findsNothing);
        },
      );

      testWidgets(
        'pops term dialog when AcademicTermForm fires onSaved callback',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onAddTermPressed!();
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsOneWidget);

          final formFinder = find.byType(AcademicTermForm);
          final formWidget = tester.widget<AcademicTermForm>(formFinder);
          formWidget.onSaved!(terms.first);
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsNothing);
        },
      );

      testWidgets(
        'pops term dialog when AcademicTermForm fires onAcademicTermDeleted',
        (tester) async {
          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onAddTermPressed!();
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsOneWidget);

          final formFinder = find.byType(AcademicTermForm);
          final formWidget = tester.widget<AcademicTermForm>(formFinder);
          formWidget.onAcademicTermDeleted!(terms.first);
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsNothing);
        },
      );
    });
  });
}
