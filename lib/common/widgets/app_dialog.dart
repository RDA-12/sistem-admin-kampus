import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Helper to shows all kinds of dialog the app has
extension AppDialogX on BuildContext {
  /// Shows a Dialog to inform user that the process user's requested
  /// successfully run
  Future<void> showSuccessDialog({
    required String title,
    required String message,
  }) {
    return showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.check_circle_rounded,
            color: context.color.primary,
          ),
          title: Text(title),
          content: Text(message),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            AppButton(
              label: 'OK',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a Dialog to inform user that the process user's requested
  /// failed to run
  Future<void> showFailedDialog({
    required String title,
    required String message,
  }) {
    return showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.cancel_rounded,
            color: context.color.error,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            AppButton(
              label: 'OK',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
