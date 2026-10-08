import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/core/core.dart';

void main() {
  group('AppResult', () {
    group('AppSuccess', () {
      test('equal on data', () {
        const testObj = AppSuccess(data: '1234');
        const a = AppSuccess(data: '1234');
        const b = AppSuccess(data: 'data 2');
        const c = AppSuccess(data: 1234);

        expect(testObj, equals(a));
        expect(testObj, isNot(equals(b)));
        expect(testObj, isNot(equals(c)));
      });
    });

    group('AppFailure', () {
      test('equal on exception', () {
        const exc = AppException('message', code: .internal);
        const testObj = AppFailure<int>(exception: exc);
        const a = AppFailure<int>(exception: exc);
        const b = AppFailure<int>(
          exception: AppException('message 2', code: .server),
        );

        expect(testObj, equals(a));
        expect(testObj, isNot(equals(b)));
      });
    });
  });
}
