import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';

/// Controller for [RoomSelector]
final class RoomSelectorController extends AppSelectorController<Room> {
  /// Creates new [RoomSelectorController] with [initial] selected
  new({super.initial, super.initialItems})
    : super(itemAsString: (it) => it.name);
}

/// Selector to select a [Room]
class RoomSelector extends StatelessWidget {
  /// Creates new [RoomSelector]
  ///
  /// It reacts to [RoomsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.label,
    required this.controller,
    super.key,
  });

  /// Controls the [Room] being selected
  final RoomSelectorController controller;

  /// Label for this room selector
  final String label;

  void _syncState(RoomsState state) {
    switch (state) {
      case RoomsInitial():
      case LoadingRooms():
        controller.isLoading = true;
        controller.exception = null;
      case RoomsLoaded(:final data):
        controller.isLoading = false;
        controller.exception = null;
        controller.items = data;
      case RoomsFailure(:final exception):
        controller.isLoading = false;
        controller.exception = exception;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoomsBloc, RoomsState>(
      listener: (context, state) => _syncState(state),
      child: AppSelector<Room>(
        label: label,
        dialogTitle: 'Pilih Ruangan',
        controller: controller,
        onPressed: () {
          _syncState(context.read<RoomsBloc>().state);
          context.read<RoomsBloc>().add(
            const RoomsSubscriptionRequested(),
          );
        },
      ),
    );
  }
}
