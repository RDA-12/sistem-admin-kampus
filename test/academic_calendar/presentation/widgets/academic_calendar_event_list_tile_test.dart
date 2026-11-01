import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

import '../../../common/helper.dart';

void main() {
  final event = AcademicCalendarEvent(
    id: 'event_1',
    academicYearId: 'year_1',
    name: 'Libur Idul Fitri',
    type: AcademicCalendarEventType.holiday,
    start: EventDateTime(
      date: DateTime(2026, 3, 20),
      time: const Time(hour: 0, minute: 0),
    ),
    end: EventDateTime(
      date: DateTime(2026, 3, 25),
      time: const Time(hour: 23, minute: 59),
    ),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    void Function()? onPressed,
    bool selected = false,
  }) {
    return tester.pumpWidgetForTest((context) {
      return AcademicCalendarEventListTile(
        selected: selected,
        event: event,
        onPressed: onPressed,
      );
    });
  }

  group('AcademicCalendarEventListTile', () {
    group('Render', () {
      testWidgets('shows event name and type and date subtitle', (
        tester,
      ) async {
        await pumpWidget(tester);

        expect(find.text(event.name), findsOneWidget);
        expect(
          find.text('Hari Libur • 20/03/2026 - 25/03/2026'),
          findsOneWidget,
        );
        expect(find.byType(AppListTile), findsOneWidget);
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

        await tester.tap(find.text(event.name));

        expect(pressed, isTrue);
      });
    });
  });
}
