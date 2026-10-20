import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/presentation/widgets/program_lecturers_list.dart';

import '../../../common/helper.dart';
import '../../../lecturer/domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<Lecturer> lecturers,
    void Function(Lecturer)? onPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CustomScrollView(
          slivers: [
            ProgramLecturersList(
              lecturers: lecturers,
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  group('ProgramLecturersList', () {
    group('Render', () {
      testWidgets(
        'shows list of lecturers with correct title and subtitle',
        (tester) async {
          await pumpWidget(tester, lecturers: lecturersMock);

          for (final lecturer in lecturersMock) {
            final finder = find.ancestor(
              of: find.text(lecturer.name),
              matching: find.byType(AppListTile),
            );
            await tester.ensureVisible(finder);
            expect(finder, findsOneWidget);
            expect(
              find.descendant(
                of: finder,
                matching: find.text(lecturer.pangkatGolongan),
              ),
              findsOneWidget,
            );
          }
        },
      );

      testWidgets('shows AppEmptyBox when lecturer list is empty', (
        tester,
      ) async {
        await pumpWidget(tester, lecturers: const []);

        expect(find.byType(AppListTile), findsNothing);
        final finder = find.byType(AppEmptyBox);
        expect(finder, findsOneWidget);
        final widget = tester.widget<AppEmptyBox>(finder);
        expect(widget.message, 'Belum ada data dosen');
      });
    });

    group('Interactions', () {
      testWidgets(
        'calls onPressed with correct lecturer when tile is pressed',
        (tester) async {
          Lecturer? pressedLecturer;
          await pumpWidget(
            tester,
            lecturers: lecturersMock,
            onPressed: (l) => pressedLecturer = l,
          );

          final target = lecturersMock.first;
          final finder = find.ancestor(
            of: find.text(target.name),
            matching: find.byType(AppListTile),
          );
          await tester.ensureVisible(finder);
          await tester.tap(finder);

          expect(pressedLecturer, target);
        },
      );
    });
  });
}
