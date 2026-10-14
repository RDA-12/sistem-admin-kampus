import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/helper.dart';
import '../../../faculty/domain/mocks.dart';

void main() {
  final program = ProgramUI(
    id: 'id',
    facultyId: facultyMock.id,
    name: 'program',
    faculty: facultyMock,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return ProgramListTile(
        selected: selected,
        program: program,
        onPressed: onPressed,
      );
    });
  }

  group('ProgramListTile', () {
    group('Render', () {
      testWidgets('shows program name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(program.name), findsOneWidget);
      });

      testWidgets('shows faculty name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(program.faculty.name), findsOneWidget);
      });

      testWidgets('shows selected AppListTile when selected is true', (
        tester,
      ) async {
        await pumpWidget(tester, selected: true);

        final finder = find.byType(AppListTile);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppListTile>(finder);
        expect(widget.selected, isTrue);
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed when pressed', (tester) async {
        var pressed = false;
        await pumpWidget(
          tester,
          onPressed: () {
            pressed = true;
          },
        );

        await tester.tap(find.text(program.name));

        expect(pressed, isTrue);
      });
    });
  });
}
