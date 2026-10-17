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
  late AcademicYearsBloc academicYearsBlocMock;

  group('AcademicYearsList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      academicYearsBlocMock = getIt<AcademicYearsBloc>();
      whenListen(
        academicYearsBlocMock,
        Stream.value(AcademicYearsLoaded(academicYearsMock)),
        initialState: AcademicYearsLoaded(academicYearsMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(AcademicYear)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return AcademicYearsList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: academicYearsBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(academicYearsBlocMock);
    });

    group('Render', () {
      testWidgets('shows create new button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator when state is LoadingAcademicYears',
        (tester) async {
          whenListen(
            academicYearsBlocMock,
            Stream.value(const LoadingAcademicYears()),
            initialState: const LoadingAcademicYears(),
          );

          await pumpWidget(tester);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows all academic years when state is AcademicYearsLoaded',
        (tester) async {
          await pumpWidget(tester);

          for (final year in academicYearsMock) {
            expect(find.text(year.name), findsOneWidget);
          }
        },
      );

      testWidgets(
        'shows AppExceptionBox when state is AcademicYearsFailure',
        (tester) async {
          whenListen(
            academicYearsBlocMock,
            Stream.value(AcademicYearsFailure(AppException.test())),
            initialState: AcademicYearsFailure(AppException.test()),
          );

          await pumpWidget(tester);

          expect(find.byType(AppExceptionBox), findsOneWidget);
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onCreatePressed when create button is pressed',
        (tester) async {
          var createPressed = false;
          await pumpWidget(
            tester,
            onCreatePressed: () {
              createPressed = true;
            },
          );

          await tester.tap(createButtonFinder);
          await tester.pumpAndSettle();

          expect(createPressed, isTrue);
        },
      );

      testWidgets(
        'calls onPressed with correct data when an academic year is pressed',
        (tester) async {
          AcademicYear? pressedYear;
          await pumpWidget(
            tester,
            onPressed: (year) {
              pressedYear = year;
            },
          );

          await tester.tap(find.text(academicYearsMock.first.name));
          await tester.pumpAndSettle();

          expect(pressedYear, equals(academicYearsMock.first));
        },
      );

      testWidgets(
        'adds AcademicYearsSubscriptionRequested when retry button pressed',
        (tester) async {
          whenListen(
            academicYearsBlocMock,
            Stream.value(AcademicYearsFailure(AppException.test())),
            initialState: AcademicYearsFailure(AppException.test()),
          );

          await pumpWidget(tester);

          final retryFinder = find.text('Coba lagi');
          await tester.tap(retryFinder);
          await tester.pumpAndSettle();

          verify(
            () => academicYearsBlocMock.add(
              const AcademicYearsSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });
  });
}
