import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/room/room.dart';

void main() {
  group('RoomFilter', () {
    test('supports value equality', () {
      const filterA = RoomFilter(facultyId: 'faculty_1');
      const filterB = RoomFilter(facultyId: 'faculty_1');
      const filterC = RoomFilter(facultyId: 'faculty_2');
      const filterD = RoomFilter();

      expect(filterA, equals(filterB));
      expect(filterA, isNot(equals(filterC)));
      expect(filterA, isNot(equals(filterD)));
      expect(filterA.props, ['faculty_1']);
      expect(filterD.props, [null]);
    });
  });
}
