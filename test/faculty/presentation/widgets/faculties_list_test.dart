import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late FacultiesBloc facultiesBlocMock;

  group('FacultyList', () {
    setUpAll(initializeMockDependencies);

    setUp(() {
      facultiesBlocMock = getIt<FacultiesBloc>();
      whenListen(
        facultiesBlocMock,
        Stream.value(FacultiesLoaded(facultiesMock)),
        initialState: FacultiesLoaded(facultiesMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Faculty)? onPressed,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return FacultiesList(
            onPressed: onPressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: facultiesBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(facultiesBlocMock);
    });

    group('Render', () {
      testWidgets('shows all faculties when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final faculty in facultiesMock) {
          final facultyFinder = find.ancestor(
            of: find.text(faculty.name),
            matching: find.byType(FacultyListTile),
          );
          await tester.ensureVisible(facultyFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<FacultiesState>.broadcast();
        when(() => facultiesBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const FacultiesInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingFaculties());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          whenListen(
            facultiesBlocMock,
            Stream.value(FacultiesFailure(AppException.test())),
            initialState: FacultiesFailure(AppException.test()),
          );

          await pumpWidget(tester);
          await tester.pumpAndSettle();

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data fakultas');
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of faculties is pressed',
        (tester) async {
          Faculty? pressedFaculty;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedFaculty = v;
            },
          );

          final facultyFinder = find.text(facultiesMock.first.name);
          await tester.ensureVisible(facultyFinder);
          await tester.pumpAndSettle();
          await tester.tap(facultyFinder);

          expect(pressedFaculty, facultiesMock.first);
        },
      );
    });
  });
}
