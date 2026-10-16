import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late ProgramSelectorController controller;
  late ProgramsBloc programsBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    programsBlocMock = getIt<ProgramsBloc>();
    whenListen(
      programsBlocMock,
      Stream.value(ProgramsLoaded(programsUIMock)),
      initialState: ProgramsLoaded(programsUIMock),
    );

    controller = ProgramSelectorController();
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return ProgramSelector(
          label: label ?? 'Label',
          controller: controller,
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

  Future<void> openSelector(
    WidgetTester tester, {
    bool pumpOnly = false,
  }) async {
    await tester.tap(find.byType(AppFormField));
    if (pumpOnly) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  group('ProgramSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = ProgramSelectorController(initial: programsMock.first);

      expect(ctrl.selected, programsMock.first);
      expect(ctrl.textEditingController.text, programsMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = programsMock.first;

      expect(controller.textEditingController.text, programsMock.first.name);
    });
  });

  group('ProgramSelector', () {
    testWidgets('configures AppSelector correctly', (tester) async {
      await pumpWidget(tester, label: 'Custom Program');

      final appSelectorFinder = find.byType(AppSelector<Program>);
      expect(appSelectorFinder, findsOneWidget);

      final appSelector = tester.widget<AppSelector<Program>>(
        appSelectorFinder,
      );
      expect(appSelector.label, 'Custom Program');
      expect(appSelector.dialogTitle, 'Pilih Program Studi');
      expect(appSelector.controller, controller);
    });

    testWidgets(
      'triggers ProgramsSubscriptionRequested when selector is pressed',
      (tester) async {
        await pumpWidget(tester);

        await openSelector(tester);

        verify(
          () => programsBlocMock.add(const ProgramsSubscriptionRequested()),
        ).called(1);
      },
    );

    testWidgets(
      'shows LoadingIndicator on dialog when state is loading',
      (tester) async {
        whenListen(
          programsBlocMock,
          Stream.value(const LoadingPrograms()),
          initialState: const LoadingPrograms(),
        );
        await pumpWidget(tester);

        await openSelector(tester, pumpOnly: true);

        expect(find.byType(LoadingIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows AppExceptionBox on dialog when state is failed',
      (tester) async {
        whenListen(
          programsBlocMock,
          Stream.value(ProgramsFailure(AppException.test())),
          initialState: ProgramsFailure(AppException.test()),
        );
        await pumpWidget(tester);

        await openSelector(tester);

        final finder = find.byType(AppExceptionBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppExceptionBox>(finder);
        expect(widget.exception, AppException.test());
      },
    );

    testWidgets(
      'ensures options showed to users is the name of Program',
      (tester) async {
        await pumpWidget(tester);

        await openSelector(tester);

        for (final p in programsUIMock) {
          final finder = find.ancestor(
            of: find.text(p.name),
            matching: find.byType(CheckboxListTile),
          );
          await tester.ensureVisible(finder);
          expect(finder, findsOneWidget);
        }
      },
    );
  });
}
