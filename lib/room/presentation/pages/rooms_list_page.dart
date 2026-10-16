import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/pages/create_room_page.dart';
import 'package:sistem_admin/room/presentation/pages/room_detail_page.dart';
import 'package:sistem_admin/room/presentation/widgets/widgets.dart';

/// Page to show rooms data
class RoomsListPage extends StatelessWidget {
  /// Creates new [RoomsListPage]
  const new({
    this.onRoomPressed,
    this.onCreatePressed,
    super.key,
  });

  /// Invoked when a room is pressed
  final void Function(String roomId)? onRoomPressed;

  /// Invoked when create button is pressed
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<RoomsBloc>()..add(const RoomsSubscriptionRequested()),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Ruangan'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: RoomsList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (room) {
                  final roomId = room.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (onRoomPressed != null) {
                      onRoomPressed?.call(roomId);
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        RoomDetailCompactRoute(roomId).push<void>(context),
                      );
                    } else {
                      unawaited(
                        RoomDetailRoute(roomId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = roomId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (onCreatePressed != null) {
                      onCreatePressed?.call();
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateRoomCompactRoute().push<void>(context),
                      );
                    } else {
                      unawaited(
                        const CreateRoomRoute().push<void>(context),
                      );
                    }
                  } else {
                    controller.data = 'create';
                  }
                },
              ),
            ),
          );
        },
        rightBuilder: (context, controller, breakPoint, constraints) {
          if (controller.data == null) return const SizedBox.shrink();
          if (controller.data == 'create') {
            return const CreateRoomPage();
          }
          return RoomDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onRoomDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
