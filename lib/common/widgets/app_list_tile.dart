import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Creates a styled [ListTile] for this app
class AppListTile extends StatelessWidget {
  /// Creates new [AppListTile]
  const new({
    required this.title,
    this.selected = false,
    this.subtitle,
    this.onPressed,
    this.trailing,
    super.key,
  });

  /// Main title to be showed
  final Widget title;

  /// Placed on bottom of [title]
  final Widget? subtitle;

  /// Invoked when this tile is pressed
  final VoidCallback? onPressed;

  /// Placed on the right of [title]
  final Widget? trailing;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: context.color.primaryContainer,
      selectedColor: context.color.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: selected
            ? BorderRadiusGeometry.circular(16)
            : BorderRadius.zero,
      ),
      title: title,
      trailing: trailing,
      subtitle: subtitle,
      onTap: onPressed,
    );
  }
}
