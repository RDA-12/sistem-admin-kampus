import 'package:material_ui/material_ui.dart';

/// Global spacing configuration for this app
abstract class AppSpacing {
  /// Returns padding for a page
  static const EdgeInsets pagePadding = EdgeInsets.all(16);

  /// Spacing between panes
  static const double paneSpacing = 24;
}
