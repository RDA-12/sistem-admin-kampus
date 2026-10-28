// Test descriptions in widget tests require descriptive length.
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

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
  late AcademicCalendarMutationBloc academicCalendarMutationBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    academicYearDetailBlocMock = getIt<AcademicYearDetailBloc>();
    academicCalendarMutationBlocMock = getIt<AcademicCalendarMutationBloc>();

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
      academicCalendarMutationBlocMock,
      Stream.value(const AcademicCalendarMutationState()),
      initialState: const AcademicCalendarMutationState(),
    );
  });

  tearDown(() {
    reset(academicYearDetailBlocMock);
    reset(academicCalendarMutationBlocMock);
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
            BlocProvider.value(value: academicCalendarMutationBlocMock),
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

      testWidgets(
        'dispatches AcademicCalendarYearUpdateRequested when AcademicYearForm saves',
        (tester) async {
          await pumpWidget(tester);

          final formFinder = find.byType(AcademicYearForm);
          final form = tester.widget<AcademicYearForm>(formFinder);
          form.onSave(
            name: '2026/2027',
            startDate: year.startDate,
            endDate: year.endDate,
          );

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarYearUpdateRequested(
                academicYear: year,
                name: '2026/2027',
                startDate: year.startDate,
                endDate: year.endDate,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'dispatches AcademicCalendarYearDeleteRequested when AcademicYearForm deletes',
        (tester) async {
          await pumpWidget(tester);

          final formFinder = find.byType(AcademicYearForm);
          final form = tester.widget<AcademicYearForm>(formFinder);
          form.onDelete?.call();

          verify(
            () => academicCalendarMutationBlocMock.add(
              AcademicCalendarYearDeleteRequested(
                academicYear: year,
              ),
            ),
          ).called(1);
        },
      );
    });

    group('Side Effects', () {
      testWidgets(
        'calls onAcademicYearDeleted when AcademicYearDeletedNotice is emitted',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          AcademicYear? deleted;
          await pumpWidget(
            tester,
            onAcademicYearDeleted: (y) {
              deleted = y;
            },
          );

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicYearDeletedNotice(year),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

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
        'pops term dialog when AcademicTermCreatedNotice is emitted',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onAddTermPressed!();
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsOneWidget);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicTermCreatedNotice(terms.first),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsNothing);
        },
      );

      testWidgets(
        'pops term dialog when AcademicTermDeletedNotice is emitted',
        (tester) async {
          final controller = StreamController<AcademicCalendarMutationState>();
          addTearDown(controller.close);

          whenListen(
            academicCalendarMutationBlocMock,
            controller.stream,
            initialState: const AcademicCalendarMutationState(),
          );

          await pumpWidget(tester);

          final finder = find.byType(AcademicYearTerms);
          final widget = tester.widget<AcademicYearTerms>(finder);
          widget.onAddTermPressed!();
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsOneWidget);

          controller.add(
            AcademicCalendarMutationState(
              notice: AcademicTermDeletedNotice(terms.first),
            ),
          );
          await tester.pumpAndSettle();

          final okFinder = find.ancestor(
            of: find.text('OK'),
            matching: find.byType(AppButton),
          );
          await tester.tap(okFinder);
          await tester.pumpAndSettle();

          expect(find.byType(AcademicTermForm), findsNothing);
        },
      );
    });
  });
}
