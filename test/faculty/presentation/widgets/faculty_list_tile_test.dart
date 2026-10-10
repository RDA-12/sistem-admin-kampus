import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/faculty/faculty.dart';

import '../../../common/helper.dart';

void main() {
  const faculty = Faculty(id: 'id', name: 'name');

  Future<void> pumpWidget(WidgetTester tester, {void Function()? onPressed}) {
    return tester.pumpWidgetForTest((context) {
      return FacultyListTile(
        faculty: faculty,
        onPressed: onPressed,
      );
    });
  }

  group('FacultyListTile', () {
    group('Render', () {
      testWidgets('shows faculty name', (tester) async {
        await pumpWidget(tester);

        expect(find.text(faculty.name), findsOneWidget);
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

        await tester.tap(find.text(faculty.name));

        expect(pressed, isTrue);
      });
    });
  });
}
