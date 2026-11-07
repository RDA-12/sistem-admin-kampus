import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';

import '../../../common/di_mocks.dart';
import '../../../common/helper.dart';
import '../../domain/mocks.dart';

void main() {
  late LecturerSelectorController controller;
  late LecturersBloc lecturersBlocMock;

  setUpAll(initializeMockDependencies);

  setUp(() {
    lecturersBlocMock = getIt<LecturersBloc>();
    whenListen(
      lecturersBlocMock,
      Stream.value(LecturersLoaded(lecturersUIMock)),
      initialState: LecturersLoaded(lecturersUIMock),
    );

    controller = LecturerSelectorController();
  });

  tearDown(() {
    reset(lecturersBlocMock);
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return LecturerSelector(
          label: label ?? 'Label',
          controller: controller,
        );
      },
      providerBuilder: (context, child) {
        return BlocProvider.value(
          value: lecturersBlocMock,
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

  group('LecturerSelectorController', () {
    test('sets itemAsString to (it) => it.name on initial', () {
      final ctrl = LecturerSelectorController(initial: lecturersMock.first);

      expect(ctrl.selected, lecturersMock.first);
      expect(ctrl.textEditingController.text, lecturersMock.first.name);
    });

    test('sets itemAsString to (it) => it.name when selected is changed', () {
      controller.selected = lecturersMock.first;

      expect(controller.textEditingController.text, lecturersMock.first.name);
    });
  });

  group('LecturerSelector', () {
    group('Render', () {
      testWidgets('configures AppSelector correctly', (tester) async {
        await pumpWidget(tester, label: 'Custom Lecturer');

        final appSelectorFinder = find.byType(AppSelector<Lecturer>);
        expect(appSelectorFinder, findsOneWidget);

        final appSelector = tester.widget<AppSelector<Lecturer>>(
          appSelectorFinder,
        );
        expect(appSelector.label, 'Custom Lecturer');
        expect(appSelector.dialogTitle, 'Pilih Dosen');
        expect(appSelector.controller, controller);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          whenListen(
            lecturersBlocMock,
            Stream.value(const LoadingLecturers()),
            initialState: const LoadingLecturers(),
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
            lecturersBlocMock,
            Stream.value(LecturersFailure(AppException.test())),
            initialState: LecturersFailure(AppException.test()),
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
        'ensures options showed to users is the name of Lecturer',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final l in lecturersMock) {
            final finder = find.ancestor(
              of: find.text(l.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
          }
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'triggers LecturersSubscriptionRequested when selector is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          verify(
            () => lecturersBlocMock.add(
              const LecturersSubscriptionRequested(),
            ),
          ).called(1);
        },
      );
    });
  });
}
