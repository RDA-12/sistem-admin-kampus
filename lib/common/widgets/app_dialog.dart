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
    return showAppDialog(
      title: title,
      contentBuilder: (_) => Text(message),
      actionsBuilder: (context) {
        return [
          AppButton(
            label: 'OK',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ];
      },
    );
  }

  /// Shows a Dialog to inform user that the process user's requested
  /// failed to run
  Future<void> showFailedDialog({
    required String title,
    required String message,
  }) {
    return showAppDialog(
      title: title,
      contentBuilder: (_) => Text(message),
      actionsBuilder: (context) {
        return [
          AppButton(
            label: 'OK',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ];
      },
    );
  }

  /// Shows confirmation dialog with [title] and [message]
  ///
  /// Returns true when the user confirmed. Otherwise, false.
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final result = await showAppDialog<bool?>(
      title: title,
      contentBuilder: (_) => Text(message),
      actionsBuilder: (context) {
        return [
          AppButton(
            type: .text,
            label: 'Batal',
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          AppButton(
            type: .text,
            label: 'OK',
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ];
      },
    );
    return result ?? false;
  }

  /// Shows styled dialog for the app
  Future<T?> showAppDialog<T>({
    required String title,
    required Widget Function(BuildContext) contentBuilder,
    List<Widget> Function(BuildContext)? actionsBuilder,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) {
        return _AppDialog(
          title: title,
          content: contentBuilder(context),
          actions: actionsBuilder?.call(context),
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
