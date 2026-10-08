import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/core/app_exception.dart';

void main() {
  group('AppException', () {
    test('equal on code', () {
      const testObj = AppException('message', code: .internal);
      const a = AppException('message something', code: .internal);
      const b = AppException('message', code: .server);

      expect(testObj, equals(a));
      expect(testObj, isNot(equals(b)));
    });
  });
}
