import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/domain.dart';

/// Creates a Button that will show confirmation dialog
/// to delete the [room]
class DeleteRoomButton extends StatelessWidget {
  /// Creates new [DeleteRoomButton]
  const new({
    required this.room,
    this.onConfirmed,
    this.isDeleting = false,
    this.disable = false,
    super.key,
  });

  /// [Room] that will be deleted
  final Room room;

  /// Invoked when user confirmed to delete [room]
  final void Function()? onConfirmed;

  /// Whether the [room] is in deleting process or not
  final bool isDeleting;

  /// Disable the button when set this to true
  final bool disable;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      type: AppButtonType.text,
      color: AppButtonColor.danger,
      leadingIcon: isDeleting
          ? const LoadingIndicator()
          : const Icon(Icons.close_rounded),
      label: 'Hapus',
      onPressed: disable
          ? null
          : () async {
              final shouldDelete = await context.showConfirmationDialog(
                title: 'Hapus ${room.name}',
                message:
                    'Data yang berhubungan dengan ${room.name} '
                    'akan tetap ada. Tapi, ruangan tersebut '
                    'tidak lagi bisa digunakan untuk proses lain',
              );
              if (!shouldDelete) return;
              onConfirmed?.call();
            },
    );
  }
}
