import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  group('CohortToDomainX', () {
    test('returns correct Cohort from CohortDb', () {
      const expected = Cohort(
        id: 'id',
        name: 'Cohort 2020',
        entryYear: 2020,
      );

      final result = CohortDb(
        id: 'id',
        name: 'Cohort 2020',
        entryYear: 2020,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(result.toDomain(), expected);
    });
  });

  group('CohortToCompanionX', () {
    test(
      'returns correct CohortsDriftCompanion from UpdateCohortParams',
      () {
        const expected = CohortsDriftCompanion(
          name: Value('Cohort 2021'),
          entryYear: Value(2021),
        );
        const cohort = Cohort(
          id: 'id',
          name: 'Cohort 2020',
          entryYear: 2020,
        );

        final result = const UpdateCohortParams(
          cohort,
          name: 'Cohort 2021',
          entryYear: 2021,
        ).toCompanion();

        expect(result, expected);

        final result2 = const UpdateCohortParams(cohort).toCompanion();

        expect(result2, const CohortsDriftCompanion());
      },
    );
  });
}
