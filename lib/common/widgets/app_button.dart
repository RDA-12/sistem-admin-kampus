import 'package:material_ui/material_ui.dart';

/// Styled [FilledButton] for this app
class AppButton extends StatelessWidget {
  /// Creates new [AppButton]
  const new({
    required this.label,
    this.onPressed,
    super.key,
  });

  /// Invoked when this button is pressed
  final VoidCallback? onPressed;

  /// Label for this button
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
