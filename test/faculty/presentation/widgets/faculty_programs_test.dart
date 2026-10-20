import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/presentation/widgets/faculty_programs.dart';
import 'package:sistem_admin/program/program.dart';

import '../../../common/helper.dart';
import '../../../program/domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<Program> programs,
    void Function(Program)? onPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CustomScrollView(
          slivers: [
            FacultyPrograms(
              programs: programs,
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  group('FacultyPrograms', () {
    group('Render', () {
      testWidgets('shows list of programs with correct title', (tester) async {
        await pumpWidget(tester, programs: programsMock);

        for (final program in programsMock) {
          final finder = find.ancestor(
            of: find.text(program.name),
            matching: find.byType(AppListTile),
          );
          await tester.ensureVisible(finder);
          expect(finder, findsOneWidget);
        }
      });

      testWidgets('shows AppEmptyBox when program list is empty', (
        tester,
      ) async {
        await pumpWidget(tester, programs: const []);

        expect(find.byType(AppListTile), findsNothing);
        final finder = find.byType(AppEmptyBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppEmptyBox>(finder);
        expect(widget.message, 'Belum ada data program studi');
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed with correct program when tile is pressed', (
        tester,
      ) async {
        Program? pressedProgram;
        await pumpWidget(
          tester,
          programs: programsMock,
          onPressed: (p) => pressedProgram = p,
        );

        final target = programsMock.first;
        final finder = find.ancestor(
          of: find.text(target.name),
          matching: find.byType(AppListTile),
        );
        await tester.ensureVisible(finder);
        await tester.tap(finder);

        expect(pressedProgram, target);
      });
    });
  });
}
