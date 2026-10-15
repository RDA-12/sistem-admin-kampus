import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

import '../helper.dart';

@immutable
class _TestItem {
  const new({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

const _testItems = [
  _TestItem(id: '1', name: 'Item 1'),
  _TestItem(id: '2', name: 'Item 2'),
  _TestItem(id: '3', name: 'Item 3'),
];

void main() {
  late AppSelectorController<_TestItem> controller;

  setUp(() {
    controller = AppSelectorController<_TestItem>(
      itemAsString: (it) => it.name,
      initialItems: _testItems,
    );
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? label,
    String? dialogTitle,
    VoidCallback? onPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return AppSelector<_TestItem>(
          label: label ?? 'Label',
          dialogTitle: dialogTitle ?? 'Pilih Item',
          controller: controller,
          onPressed: onPressed,
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

  group('AppSelectorController', () {
    test('initial value configures text and selected', () {
      final ctrl = AppSelectorController<_TestItem>(
        itemAsString: (it) => it.name,
        initial: _testItems.first,
        initialItems: _testItems,
      );

      expect(ctrl.selected, _testItems.first);
      expect(ctrl.textEditingController.text, _testItems.first.name);
      expect(ctrl.items, _testItems);
    });

    test('setting selected updates text and notifies listeners', () {
      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..selected = _testItems[1];

      expect(notified, isTrue);
      expect(controller.selected, _testItems[1]);
      expect(controller.textEditingController.text, _testItems[1].name);
    });

    test('setting items updates items and notifies listeners', () {
      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..items = [_testItems.first];

      expect(notified, isTrue);
      expect(controller.items, [_testItems.first]);
    });

    test('setting isLoading updates isLoading and notifies listeners', () {
      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..isLoading = true;

      expect(notified, isTrue);
      expect(controller.isLoading, isTrue);
    });

    test('setting exception updates exception and notifies listeners', () {
      var notified = false;
      final exception = AppException.test();
      controller
        ..addListener(() => notified = true)
        ..exception = exception;

      expect(notified, isTrue);
      expect(controller.exception, exception);
    });

    test('clear resets selected and text and notifies listeners', () {
      controller.selected = _testItems.first;
      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..clear();

      expect(notified, isTrue);
      expect(controller.selected, isNull);
      expect(controller.textEditingController.text, isEmpty);
    });
  });

  group('AppSelector', () {
    group('Render', () {
      testWidgets('shows selected item on field', (tester) async {
        await pumpWidget(tester);

        controller.selected = _testItems.first;
        await tester.pumpAndSettle();

        expect(find.text(_testItems.first.name), findsOneWidget);
      });

      testWidgets(
        'shows LoadingIndicator on dialog when state is loading',
        (tester) async {
          controller.isLoading = true;
          await pumpWidget(tester);

          await openSelector(tester, pumpOnly: true);

          expect(find.byType(LoadingIndicator), findsOneWidget);
        },
      );

      testWidgets(
        'shows AppExceptionBox on dialog when state is failed',
        (tester) async {
          controller.exception = AppException.test();
          await pumpWidget(tester);

          await openSelector(tester);

          final finder = find.byType(AppExceptionBox);
          expect(finder, findsOneWidget);
          final widget = tester.widget<AppExceptionBox>(finder);
          expect(widget.exception, AppException.test());
          expect(widget.title, 'Gagal mengambil data');
        },
      );

      testWidgets(
        'shows correct list of items on dialog when state is loaded',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          for (final item in _testItems) {
            final finder = find.ancestor(
              of: find.text(item.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
          }
        },
      );

      testWidgets(
        'shows selected item on dialog when state is loaded',
        (tester) async {
          await pumpWidget(tester);
          controller.selected = _testItems.first;

          await openSelector(tester);

          for (final item in _testItems) {
            final finder = find.ancestor(
              of: find.text(item.name),
              matching: find.byType(CheckboxListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
            final widget = tester.widget<CheckboxListTile>(finder);
            expect(widget.selected, item == _testItems.first);
            expect(widget.value, item == _testItems.first);
          }
        },
      );
    });

    group('Interactions', () {
      testWidgets(
        'open selector dialog when field is pressed',
        (tester) async {
          await pumpWidget(tester);

          await openSelector(tester);

          expect(find.text('Pilih Item'), findsOneWidget);
        },
      );

      testWidgets(
        'invokes onPressed when field is pressed',
        (tester) async {
          var pressed = false;
          await pumpWidget(
            tester,
            onPressed: () {
              pressed = true;
            },
          );

          await openSelector(tester);

          expect(pressed, isTrue);
        },
      );

      testWidgets(
        'can select an item',
        (tester) async {
          await pumpWidget(tester);
          final first = _testItems.first;

          expect(find.text(first.name), findsNothing);
          await openSelector(tester);
          final firstFinder = find.ancestor(
            of: find.text(first.name),
            matching: find.byType(CheckboxListTile),
          );
          await tester.ensureVisible(firstFinder);
          await tester.tap(firstFinder);
          await tester.pumpAndSettle();

          expect(find.text(first.name), findsOneWidget);
          expect(controller.selected, first);
        },
      );

      testWidgets(
        'unchecking selected item dismisses dialog without selection',
        (tester) async {
          await pumpWidget(tester);
          controller.selected = _testItems.first;
          await tester.pumpAndSettle();

          await openSelector(tester);
          final firstFinder = find.ancestor(
            of: find.text(_testItems.first.name),
            matching: find.byType(CheckboxListTile),
          );
          await tester.ensureVisible(firstFinder);
          await tester.tap(firstFinder);
          await tester.pumpAndSettle();

          expect(controller.selected, isNull);
        },
      );
    });
  });
}
