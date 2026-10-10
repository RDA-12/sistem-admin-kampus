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
        return _AppDialog(
          title: title,
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

  /// Shows a Dialog to inform user that the process user's requested
  /// failed to run
  Future<void> showFailedDialog({
    required String title,
    required String message,
  }) {
    return showDialog(
      context: this,
      builder: (context) {
        return _AppDialog(
          title: title,
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

class _AppDialog extends StatelessWidget {
  const new({
    required this.title,
    required this.content,
    this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      title: Text(title),
      content: content,
      actionsAlignment: MainAxisAlignment.end,
      actions: actions,
    );
  }
}
