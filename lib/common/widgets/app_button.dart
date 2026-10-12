import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Possible types of [AppButton]
enum AppButtonType {
  /// Filled type, showing button in primary color
  filled,

  /// Text type, showing button in text only
  text,
}

/// Possible colors of [AppButton]
enum AppButtonColor {
  /// Basic color
  basic,

  /// Danger color
  ///
  /// Typically used for delete function
  danger;

  /// Returns background color for this color type
  Color background(BuildContext context, {required AppButtonType type}) {
    switch (type) {
      case AppButtonType.filled:
        switch (this) {
          case AppButtonColor.basic:
            return context.color.primary;
          case AppButtonColor.danger:
            return context.color.error;
        }
      case AppButtonType.text:
        return Colors.transparent;
    }
  }

  /// Returns foreground color for this color type
  Color foreground(BuildContext context, {required AppButtonType type}) {
    switch (type) {
      case AppButtonType.filled:
        switch (this) {
          case AppButtonColor.basic:
            return context.color.onPrimary;
          case AppButtonColor.danger:
            return context.color.onError;
        }
      case AppButtonType.text:
        switch (this) {
          case AppButtonColor.basic:
            return context.color.primary;
          case AppButtonColor.danger:
            return context.color.error;
        }
    }
  }
}

/// Styled [FilledButton] for this app
class AppButton extends StatelessWidget {
  /// Creates new [AppButton]
  const new({
    required this.label,
    this.type = AppButtonType.filled,
    this.color = AppButtonColor.basic,
    this.onPressed,
    this.leadingIcon,
    super.key,
  });

  /// Type of the button
  final AppButtonType type;

  /// Color type of the button
  final AppButtonColor color;

  /// Invoked when this button is pressed
  final VoidCallback? onPressed;

  /// Label for this button
  final String label;

  /// Icon to be placed before [label]
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);

    switch (type) {
      case AppButtonType.filled:
        final style = FilledButton.styleFrom(
          fixedSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: context.text.titleSmall,
          foregroundColor: color.foreground(context, type: type),
          backgroundColor: color.background(context, type: type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(100),
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
      case AppButtonType.text:
        final style = TextButton.styleFrom(
          fixedSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: context.text.titleSmall,
          foregroundColor: color.foreground(context, type: type),
          backgroundColor: color.background(context, type: type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
        );

        if (leadingIcon != null) {
          return TextButton.icon(
            onPressed: onPressed,
            label: child,
            icon: leadingIcon,
            iconAlignment: IconAlignment.start,
            style: style,
          );
        }

        return TextButton(
          onPressed: onPressed,
          style: style,
          child: child,
        );
    }
  }
}
