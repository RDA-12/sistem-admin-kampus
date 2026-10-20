import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/presentation/widgets/faculty_rooms.dart';
import 'package:sistem_admin/room/room.dart';

import '../../../common/helper.dart';
import '../../../room/domain/mocks.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required List<Room> rooms,
    void Function(Room)? onPressed,
  }) {
    return tester.pumpWidgetForTest(
      (context) {
        return CustomScrollView(
          slivers: [
            FacultyRooms(
              rooms: rooms,
              onPressed: onPressed,
            ),
          ],
        );
      },
    );
  }

  group('FacultyRooms', () {
    group('Render', () {
      testWidgets('shows list of rooms with correct title', (tester) async {
        await pumpWidget(tester, rooms: roomsMock);

        for (final room in roomsMock) {
          final finder = find.ancestor(
            of: find.text(room.name),
            matching: find.byType(AppListTile),
          );
          await tester.ensureVisible(finder);
          expect(finder, findsOneWidget);
        }
      });

      testWidgets('handles empty room list', (tester) async {
        await pumpWidget(tester, rooms: const []);

        expect(find.byType(AppListTile), findsNothing);
      });
    });

    group('Interactions', () {
      testWidgets('calls onPressed with correct room when tile is pressed', (
        tester,
      ) async {
        Room? pressedRoom;
        await pumpWidget(
          tester,
          rooms: roomsMock,
          onPressed: (r) => pressedRoom = r,
        );

        final target = roomsMock.first;
        final finder = find.ancestor(
          of: find.text(target.name),
          matching: find.byType(AppListTile),
        );
        await tester.ensureVisible(finder);
        await tester.tap(finder);

        expect(pressedRoom, target);
      });
    });
  });
}
