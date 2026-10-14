import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late ProgramsBloc programsBlocMock;

  group('ProgramsList', () {
    final createButtonFinder = find.ancestor(
      of: find.text('Buat baru'),
      matching: find.byType(AppButton),
    );

    setUpAll(initializeMockDependencies);

    setUp(() {
      programsBlocMock = getIt<ProgramsBloc>();
      whenListen(
        programsBlocMock,
        Stream.value(ProgramsLoaded(programsUIMock)),
        initialState: ProgramsLoaded(programsUIMock),
      );
    });

    Future<void> pumpWidget(
      WidgetTester tester, {
      void Function(Program)? onPressed,
      void Function()? onCreatePressed,
      String? selectedId,
    }) {
      return tester.pumpWidgetForTest(
        (context) {
          return ProgramsList(
            selectedId: selectedId,
            onPressed: onPressed,
            onCreatePressed: onCreatePressed,
          );
        },
        providerBuilder: (context, child) {
          return BlocProvider.value(
            value: programsBlocMock,
            child: child,
          );
        },
      );
    }

    tearDown(() {
      reset(programsBlocMock);
    });

    group('Render', () {
      testWidgets('shows all programs when state is loaded', (tester) async {
        await pumpWidget(tester);

        for (final program in programsUIMock) {
          final programFinder = find.ancestor(
            of: find.text(program.name),
            matching: find.byType(ProgramListTile),
          );
          await tester.ensureVisible(programFinder);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('shows LoadingIndicator when state is loading/initial', (
        tester,
      ) async {
        final controller = StreamController<ProgramsState>.broadcast();
        when(() => programsBlocMock.stream)
            .thenAnswer((_) => controller.stream);

        await pumpWidget(tester);
        controller.add(const ProgramsInitial());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);

        controller.add(const LoadingPrograms());
        await tester.pump();

        expect(find.byType(LoadingIndicator), findsOneWidget);
      });

      testWidgets(
        'shows AppExceptionBox when state is failure',
        (tester) async {
          whenListen(
            programsBlocMock,
            Stream.value(ProgramsFailure(AppException.test())),
            initialState: ProgramsFailure(AppException.test()),
          );

          await pumpWidget(tester);
          await tester.pumpAndSettle();

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data program studi');
        },
      );

      testWidgets('shows create button', (tester) async {
        await pumpWidget(tester);

        expect(createButtonFinder, findsOneWidget);
      });

      testWidgets('shows selected ProgramListTile', (tester) async {
        await pumpWidget(tester, selectedId: programsUIMock.first.id);

        for (final program in programsUIMock) {
          final finder = find.ancestor(
            of: find.text(program.name),
            matching: find.byType(ProgramListTile),
          );
          await tester.ensureVisible(finder);
          final widget = tester.widget<ProgramListTile>(finder);
          expect(widget.selected, program.id == programsUIMock.first.id);
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct data '
        'when one of programs is pressed',
        (tester) async {
          Program? pressedProgram;
          await pumpWidget(
            tester,
            onPressed: (v) {
              pressedProgram = v;
            },
          );

          final programFinder = find.text(programsUIMock.first.name);
          await tester.ensureVisible(programFinder);
          await tester.pumpAndSettle();
          await tester.tap(programFinder);

          expect(pressedProgram, programsUIMock.first);
        },
      );

      testWidgets(
        'calls onCreatePressed when create button is pressed',
        (tester) async {
          var pressed = false;
          await pumpWidget(
            tester,
            onCreatePressed: () {
              pressed = true;
            },
          );

          await tester.tap(createButtonFinder);

          expect(pressed, isTrue);
        },
      );
    });
  });
}
