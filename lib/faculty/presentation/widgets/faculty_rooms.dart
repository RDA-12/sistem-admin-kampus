import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/room.dart';

/// Shows list of [Room] belonging to a faculty as a sliver
class FacultyRooms extends StatelessWidget {
  /// Creates new [FacultyRooms]
  const new({
    required this.rooms,
    this.onPressed,
    super.key,
  });

  /// List of [Room] to show
  final List<Room> rooms;

  /// Invoked when one of rooms is pressed
  final void Function(Room)? onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return AppListTile(
          title: Text(room.name),
          onPressed: onPressed == null ? null : () => onPressed!(room),
        );
      },
    );
  }
}
