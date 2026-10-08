import 'package:material_ui/material_ui.dart';

/// Extension to helps get theme from [BuildContext]
extension ThemeX on BuildContext {
  /// Returns active [ColorScheme]
  ColorScheme get color => ColorScheme.of(this);

  /// Returns active [TextTheme]
  TextTheme get text => TextTheme.of(this);

  /// Returns insets [Padding] for page
  EdgeInsets get pagePadding => const EdgeInsets.all(16);
}
