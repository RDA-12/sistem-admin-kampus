import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  group('Time', () {
    test('equal on hour and minute', () {
      const testObj = Time(hour: 8, minute: 30);
      const a = Time(hour: 8, minute: 30);
      const b = Time(hour: 9, minute: 30);
      const c = Time(hour: 8, minute: 0);

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
    });
  });

  group('EventDateTime', () {
    test('equal on date and time', () {
      final date = DateTime(2025, 9);
      const time = Time(hour: 8, minute: 30);
      final testObj = EventDateTime(date: date, time: time);
      final a = EventDateTime(date: date, time: time);
      final b = EventDateTime(
        date: DateTime(2025, 9, 2),
        time: time,
      );
      final c = EventDateTime(
        date: date,
        time: const Time(hour: 9, minute: 30),
      );

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
      expect(testObj, isNot(equals(c)));
    });
  });
}
