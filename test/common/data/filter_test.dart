import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/common/common.dart';

final class _TestFilter extends Filter {
  const new();
}

void main() {
  group('Filter', () {
    test('props is empty by default', () {
      const filter1 = _TestFilter();
      const filter2 = _TestFilter();

      expect(filter1.props, isEmpty);
      expect(filter1, equals(filter2));
    });
  });

  group('NoFilter', () {
    test('supports value equality', () {
      const filter1 = NoFilter();
      const filter2 = NoFilter();

      expect(filter1.props, isEmpty);
      expect(filter1, equals(filter2));
      expect(filter1, isA<Filter>());
    });
  });
}
