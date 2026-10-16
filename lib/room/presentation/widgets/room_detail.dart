import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/widgets/room_form.dart';

/// Shows detail of a room
class RoomDetail extends StatelessWidget {
  /// Creates new [RoomDetail]
  ///
  /// It reacts to [RoomDetailBloc], [FacultiesBloc],
  /// and [RoomMutationBloc] state changes.
  /// So, ensure to provide it with that bloc.
  const new({
    this.onRetryPressed,
    this.onRoomDeleted,
    super.key,
  });

  /// Invoked when user press retry button
  final void Function()? onRetryPressed;

  /// Invoked when a room has been deleted
  final void Function(Room)? onRoomDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomDetailBloc, RoomDetailState>(
      builder: (context, state) {
        switch (state) {
          case RoomDetailInitial():
          case LoadingRoomDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case RoomDetailLoaded(:final room):
            return RoomForm(
              initial: room,
              onRoomDeleted: onRoomDeleted,
            );
          case RoomDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data ruangan',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
