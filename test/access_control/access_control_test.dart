import 'package:flutter_test/flutter_test.dart';
import 'package:sistem_admin/access_control/access_control.dart';

void main() {
  group('AccessControl', () {
    final accessControl = AccessControl();
    group('permissionCheck', () {
      // TODO(RDA-12): test AccessControl
      group('ResourceType.faculty', () {
        test('returns false when user dont have permission', () async {
          final result = await accessControl.permissionCheck(
            action: .create,
            resource: .faculty,
          );

          expect(result, isFalse);
        });
      });
    });
  });
}
