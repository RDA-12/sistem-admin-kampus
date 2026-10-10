import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Styled [FilledButton] for this app
class AppButton extends StatelessWidget {
  /// Creates new [AppButton]
  const new({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    super.key,
  });

  /// Invoked when this button is pressed
  final VoidCallback? onPressed;

  /// Label for this button
  final String label;

  /// Icon to be placed before [label]
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    final style = FilledButton.styleFrom(
      fixedSize: const Size.fromHeight(56),
      textStyle: context.text.titleMedium?.copyWith(
        color: context.color.onPrimary,
      ),
      padding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
    );

    if (leadingIcon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        label: child,
        icon: leadingIcon,
        iconAlignment: IconAlignment.start,
        style: style,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}
