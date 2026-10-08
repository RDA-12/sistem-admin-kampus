import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');

  group('FacultyForm', () {
    Future<void> pumpWidget(
      WidgetTester tester, {
      Faculty? initial,
      void Function(String)? onSaved,
    }) {
      return tester.pumpWidgetForTest(
        (context) => FacultyForm(
          initial: initial,
          onSaved: onSaved,
        ),
      );
    }

    final nameFieldFinder = find.ancestor(
      of: find.text('Nama Fakultas *'),
      matching: find.byType(TextFormField),
    );
    final saveButtonFinder = find.ancestor(
      of: find.text('Simpan'),
      matching: find.byType(AppButton),
    );

    group('Render', () {
      testWidgets('shows name field', (tester) async {
        await pumpWidget(tester);

        expect(
          nameFieldFinder,
          findsOneWidget,
        );
      });

      testWidgets(
        'shows correct save button '
        'when initial is not provided',
        (tester) async {
          await pumpWidget(tester);

          expect(
            saveButtonFinder,
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'shows correct save button '
        'when initial is provided',
        (tester) async {
          await pumpWidget(tester, initial: faculty);

          expect(
            find.ancestor(
              of: find.text('Perbarui'),
              matching: find.byType(AppButton),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets('shows initial faculty when provided', (tester) async {
        await pumpWidget(tester, initial: faculty);

        expect(find.text(faculty.name), findsOneWidget);
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onSaved when save button pressed with valid fields',
        (tester) async {
          String? name;
          await pumpWidget(
            tester,
            onSaved: (val) => name = val,
          );

          await tester.enterText(nameFieldFinder, 'text');
          await tester.tap(saveButtonFinder);
          await tester.pumpAndSettle();

          expect(name, 'text');
        },
      );
    });
  });
}
