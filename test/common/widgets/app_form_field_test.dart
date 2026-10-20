import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/widgets/app_form_field.dart';

import '../helper.dart';

class _TestWidget extends StatefulWidget {
  const new({required this.builder});

  final Widget Function(BuildContext) builder;

  @override
  State<_TestWidget> createState() => __TestWidgetState();
}

class __TestWidgetState extends State<_TestWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          widget.builder(context),
          FilledButton(
            onPressed: () {
              _formKey.currentState?.validate();
            },
            child: const Text('save'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('AppFormField', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String label = 'Label',
      bool isRequired = true,
      TextEditingController? controller,
      String? Function(String?)? validator,
      bool readOnly = false,
      VoidCallback? onPressed,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
    }) {
      return tester.pumpWidgetForTest(
        (context) => _TestWidget(
          builder: (context) => AppFormField(
            controller: controller,
            isRequired: isRequired,
            label: label,
            validator: validator,
            readOnly: readOnly,
            onPressed: onPressed,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ),
      );
    }

    group('Render', () {
      testWidgets('shows correct label '
          'when isRequired is true', (tester) async {
        await pumpWidget(tester, label: 'Test');

        expect(find.text('Test *'), findsOneWidget);
      });

      testWidgets('shows correct label '
          'when isRequired is false', (tester) async {
        await pumpWidget(tester, label: 'Test', isRequired: false);

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('uses controller when provided', (tester) async {
        final controller = TextEditingController();

        await pumpWidget(tester, controller: controller);

        await tester.enterText(find.byType(TextFormField), 'text');

        expect(controller.text, 'text');
      });

      testWidgets(
        'passes keyboardType to underlying TextField',
        (tester) async {
          await pumpWidget(
            tester,
            keyboardType: TextInputType.number,
          );

          final textFieldFinder = find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          );
          expect(textFieldFinder, findsOneWidget);

          final textField = tester.widget<TextField>(textFieldFinder);
          expect(textField.keyboardType, TextInputType.number);
        },
      );

      testWidgets(
        'passes inputFormatters to underlying TextField',
        (tester) async {
          final formatters = [FilteringTextInputFormatter.digitsOnly];

          await pumpWidget(
            tester,
            inputFormatters: formatters,
          );

          final textFieldFinder = find.descendant(
            of: find.byType(TextFormField),
            matching: find.byType(TextField),
          );
          expect(textFieldFinder, findsOneWidget);

          final textField = tester.widget<TextField>(textFieldFinder);
          expect(textField.inputFormatters, formatters);
        },
      );

      testWidgets('shows required error '
          'when isRequired is true and save empty field', (tester) async {
        await pumpWidget(tester);

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(find.text('Kolom ini wajib diisi'), findsOneWidget);
      });

      testWidgets(
        'shows validator error message '
        'when validator is provided and save invalid field',
        (tester) async {
          await pumpWidget(
            tester,
            validator: (value) {
              final parsed = int.tryParse(value!);
              if (parsed == null) return 'invalid content';
              return null;
            },
          );

          await tester.enterText(find.byType(TextFormField), 'text');
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();

          expect(find.text('invalid content'), findsOneWidget);
        },
      );

      testWidgets('cannot enter text when readOnly is true', (tester) async {
        await pumpWidget(
          tester,
          readOnly: true,
        );

        await tester.enterText(find.byType(TextFormField), 'text');
        await tester.pumpAndSettle();

        expect(find.text('text'), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed when field is pressed', (tester) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.byType(TextFormField));

        expect(pressed, isTrue);
      });
    });
  });

  group('AppNumberFormFieldController', () {
    test('initial value configures text and value', () {
      final controller = AppNumberFormFieldController(initial: 42);
      addTearDown(controller.dispose);

      expect(controller.value, 42);
      expect(controller.textEditingController.text, '42');
    });

    test('defaults value to 0 and empty text when initial is null', () {
      final controller = AppNumberFormFieldController();
      addTearDown(controller.dispose);

      expect(controller.value, 0);
      expect(controller.textEditingController.text, isEmpty);
    });

    test('setting value updates value and text', () {
      final controller = AppNumberFormFieldController()..value = 99;
      addTearDown(controller.dispose);

      expect(controller.value, 99);
      expect(controller.textEditingController.text, '99');
    });

    test('parses valid number when text changes', () {
      final controller = AppNumberFormFieldController();
      addTearDown(controller.dispose);

      controller.textEditingController.text = '123.5';

      expect(controller.value, 123.5);
    });

    test('resets value to 0 when text is not a valid number', () {
      final controller = AppNumberFormFieldController(initial: 10);
      addTearDown(controller.dispose);

      controller.textEditingController.text = 'invalid';

      expect(controller.value, 0);
    });

    test('clear resets value to 0 and clears text', () {
      final controller = AppNumberFormFieldController(initial: 10)..clear();
      addTearDown(controller.dispose);

      expect(controller.value, 0);
      expect(controller.textEditingController.text, isEmpty);
    });
  });

  group('AppNumberFormField', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      String label = 'Label',
      bool isRequired = true,
      AppNumberFormFieldController? controller,
      String? Function(num)? validator,
      bool readOnly = false,
      List<TextInputFormatter>? inputFormatters,
    }) {
      return tester.pumpWidgetForTest(
        (context) => _TestWidget(
          builder: (context) => AppNumberFormField(
            controller: controller,
            isRequired: isRequired,
            label: label,
            validator: validator,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
          ),
        ),
      );
    }

    group('Render', () {
      testWidgets('configures AppFormField correctly', (tester) async {
        final controller = AppNumberFormFieldController(initial: 10);
        addTearDown(controller.dispose);
        final formatters = [FilteringTextInputFormatter.digitsOnly];

        await pumpWidget(
          tester,
          label: 'Custom Number',
          isRequired: false,
          readOnly: true,
          controller: controller,
          inputFormatters: formatters,
        );

        final appFormFieldFinder = find.byType(AppFormField);
        expect(appFormFieldFinder, findsOneWidget);

        final appFormField = tester.widget<AppFormField>(appFormFieldFinder);
        expect(appFormField.label, 'Custom Number');
        expect(appFormField.isRequired, isFalse);
        expect(appFormField.readOnly, isTrue);
        expect(appFormField.controller, controller.textEditingController);
        expect(
          appFormField.keyboardType,
          const TextInputType.numberWithOptions(decimal: true),
        );
        expect(appFormField.inputFormatters, formatters);
      });

      testWidgets('does not show error '
          'when isRequired is false and save empty field', (tester) async {
        await pumpWidget(tester, isRequired: false);

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(find.text('Kolom ini wajib diisi'), findsNothing);
        expect(find.text('Angka tidak valid'), findsNothing);
      });

      testWidgets('shows invalid number error '
          'when entered text is not a number', (tester) async {
        await pumpWidget(tester);

        await tester.enterText(find.byType(TextFormField), 'abc');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(find.text('Angka tidak valid'), findsOneWidget);
      });

      testWidgets(
        'shows validator error message '
        'when validator is provided and save invalid field',
        (tester) async {
          await pumpWidget(
            tester,
            validator: (value) {
              if (value <= 0) return 'Harus lebih dari 0';
              return null;
            },
          );

          await tester.enterText(find.byType(TextFormField), '0');
          await tester.tap(find.byType(FilledButton));
          await tester.pumpAndSettle();

          expect(find.text('Harus lebih dari 0'), findsOneWidget);
        },
      );
    });
  });
}
