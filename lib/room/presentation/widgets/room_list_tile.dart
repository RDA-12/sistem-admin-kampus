import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/presentation/models.dart';

/// Shows a [ListTile] with [RoomUI] data
class RoomListTile extends StatelessWidget {
  /// Creates new [RoomListTile]
  const new({
    required this.room,
    this.onPressed,
    this.selected = false,
    super.key,
  });

  /// [RoomUI] data that will be shown
  final RoomUI room;

  /// Invoked when this room tile is pressed
  final VoidCallback? onPressed;

  /// Whether this tile is selected or not
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      selected: selected,
      title: Text(room.name),
      subtitle: Text(room.faculty.name),
      trailing: const Icon(Icons.chevron_right_rounded),
      onPressed: onPressed,
    );
  }
}
