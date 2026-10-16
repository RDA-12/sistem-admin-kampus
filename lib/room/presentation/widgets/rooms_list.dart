import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/widgets/room_list_tile.dart';

/// Shows list of [Room] data
class RoomsList extends StatelessWidget {
  /// Creates new [RoomsList]
  ///
  /// It reacts to [RoomsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected room
  final String? selectedId;

  /// Invoked when one of rooms is pressed
  final void Function(Room)? onPressed;

  /// Invoked when user press create button
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: .end,
          children: [
            AppButton(
              label: 'Buat baru',
              onPressed: onCreatePressed,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<RoomsBloc, RoomsState>(
            builder: (context, state) {
              switch (state) {
                case LoadingRooms():
                case RoomsInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case RoomsLoaded(:final data):
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final room = data[index];
                      return RoomListTile(
                        room: room,
                        selected: room.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(room);
                              },
                      );
                    },
                  );
                case RoomsFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data ruangan',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<RoomsBloc>().add(
                          const RoomsSubscriptionRequested(),
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
