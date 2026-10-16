import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  final start = DateTime(2025, 9);
  final end = DateTime(2026, 8, 31);

  group('AcademicYearToDomainX', () {
    test('returns correct AcademicYear from AcademicYearDb', () {
      final expected = AcademicYear(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
      );

      final result = AcademicYearDb(
        id: 'id',
        name: '2025/2026',
        startDate: start,
        endDate: end,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('AcademicYearToCompanionX', () {
    test(
      'returns correct AcademicYearsDriftCompanion from '
      'UpdateAcademicYearParams',
      () {
        final newStart = DateTime(2025, 10);
        final newEnd = DateTime(2026, 7, 31);
        final expected = AcademicYearsDriftCompanion(
          name: const Value('2026/2027'),
          startDate: Value(newStart),
          endDate: Value(newEnd),
        );
        final year = AcademicYear(
          id: 'id',
          name: '2025/2026',
          startDate: start,
          endDate: end,
        );
        final result = UpdateAcademicYearParams(
          year,
          name: '2026/2027',
          startDate: newStart,
          endDate: newEnd,
        ).toCompanion();

        expect(result, expected);

        final result2 = UpdateAcademicYearParams(year).toCompanion();

        expect(result2, const AcademicYearsDriftCompanion());
      },
    );
  });

  group('AcademicTermToDomainX', () {
    test('returns correct AcademicTerm from AcademicTermDb', () {
      final termStart = DateTime(2025, 9);
      final termEnd = DateTime(2026, 1, 31);
      final expected = AcademicTerm(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: termStart,
        endDate: termEnd,
      );

      final result = AcademicTermDb(
        id: 'id',
        academicYearId: 'year_1',
        name: 'Ganjil',
        startDate: termStart,
        endDate: termEnd,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('AcademicTermToCompanionX', () {
    test(
      'returns correct AcademicTermsDriftCompanion from '
      'UpdateAcademicTermParams',
      () {
        final newStart = DateTime(2026, 2);
        final newEnd = DateTime(2026, 6, 30);
        final expected = AcademicTermsDriftCompanion(
          academicYearId: const Value('year_2'),
          name: const Value('Genap'),
          startDate: Value(newStart),
          endDate: Value(newEnd),
        );

        final term = AcademicTerm(
          id: 'id',
          academicYearId: 'year_1',
          name: 'Ganjil',
          startDate: DateTime(2025, 9),
          endDate: DateTime(2026, 1, 31),
        );

        final result = UpdateAcademicTermParams(
          term,
          academicYearId: 'year_2',
          name: 'Genap',
          startDate: newStart,
          endDate: newEnd,
        ).toCompanion();

        expect(result, expected);

        final result2 = UpdateAcademicTermParams(term).toCompanion();

        expect(result2, const AcademicTermsDriftCompanion());
      },
    );
  });
}
