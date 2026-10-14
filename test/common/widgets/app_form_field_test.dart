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
}
