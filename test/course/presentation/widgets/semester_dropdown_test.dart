import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/course/course.dart';

import '../../../common/helper.dart';

void main() {
  group('SemesterDropdownController', () {
    test('initial value configures text and value', () {
      final controller = SemesterDropdownController(initial: 3);
      addTearDown(controller.dispose);

      expect(controller.value, 3);
      expect(controller.textEditingController.text, '3');
    });

    test('defaults value to 0 and empty text when initial is null', () {
      final controller = SemesterDropdownController();
      addTearDown(controller.dispose);

      expect(controller.value, 0);
      expect(controller.textEditingController.text, isEmpty);
    });

    test('setting value updates value and text', () {
      final controller = SemesterDropdownController()..value = 5;
      addTearDown(controller.dispose);

      expect(controller.value, 5);
      expect(controller.textEditingController.text, '5');
    });

    test('parses valid integer when text changes', () {
      final controller = SemesterDropdownController();
      addTearDown(controller.dispose);

      controller.textEditingController.text = '8';

      expect(controller.value, 8);
    });

    test('resets value to 0 when text is not a valid integer', () {
      final controller = SemesterDropdownController(initial: 4);
      addTearDown(controller.dispose);

      controller.textEditingController.text = 'invalid';

      expect(controller.value, 0);
    });

    test('clear resets value to 0 and clears text', () {
      final controller = SemesterDropdownController(initial: 4)..clear();
      addTearDown(controller.dispose);

      expect(controller.value, 0);
      expect(controller.textEditingController.text, isEmpty);
    });
  });

  group('SemesterDropdown', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      SemesterDropdownController? controller,
    }) {
      return tester.pumpWidgetForTest(
        (context) => SemesterDropdown(
          controller: controller,
        ),
      );
    }

    group('Render', () {
      testWidgets('shows Semester * label', (tester) async {
        await pumpWidget(tester);

        expect(find.text('Semester *'), findsOneWidget);
      });

      testWidgets('renders DropdownMenu with 1 to 14 entries', (tester) async {
        final controller = SemesterDropdownController(initial: 2);
        addTearDown(controller.dispose);

        await pumpWidget(tester, controller: controller);

        final dropdownFinder = find.byType(DropdownMenu<int>);
        expect(dropdownFinder, findsOneWidget);

        final dropdown = tester.widget<DropdownMenu<int>>(dropdownFinder);
        expect(dropdown.controller, controller.textEditingController);
        expect(dropdown.initialSelection, 2);
        expect(dropdown.dropdownMenuEntries.length, 14);
        for (var i = 0; i < 14; i++) {
          final entry = dropdown.dropdownMenuEntries[i];
          expect(entry.value, i + 1);
          expect(entry.label, '${i + 1}');
        }
      });
    });

    group('Interactions', () {
      testWidgets(
        'selecting a semester updates controller value and text',
        (tester) async {
          final controller = SemesterDropdownController();
          addTearDown(controller.dispose);

          await pumpWidget(tester, controller: controller);

          await tester.tap(find.byType(DropdownMenu<int>));
          await tester.pumpAndSettle();

          final optionFinder = find.descendant(
            of: find.byType(MenuItemButton),
            matching: find.text('4'),
          );
          await tester.tap(optionFinder.last);
          await tester.pumpAndSettle();

          expect(controller.value, 4);
          expect(controller.textEditingController.text, '4');
        },
      );
    });
  });
}
