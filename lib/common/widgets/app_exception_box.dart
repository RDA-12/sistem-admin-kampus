import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Shows exception in a Box
class AppExceptionBox extends StatelessWidget {
  /// Creates new [AppExceptionBox]
  const new({
    required this.title,
    required this.exception,
    this.onRetryPressed,
    super.key,
  });

  /// Title for the exception
  final String title;

  /// Exception that will be showed in
  final AppException exception;

  /// Invoked when user press retry button
  ///
  /// If it null, it will not shows the restart button
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      mainAxisAlignment: .center,
      children: [
        Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.text.titleMedium?.copyWith(fontWeight: .bold),
            ),
            Text(
              exception.code.message,
              style: context.text.bodyMedium,
            ),
          ],
        ),
        if (onRetryPressed != null)
          AppButton(
            leadingIcon: const Icon(Icons.refresh_rounded),
            label: 'Coba lagi',
            onPressed: onRetryPressed,
          ),
      ],
    );
  }
}
