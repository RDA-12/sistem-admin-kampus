import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/widgets/widgets.dart';

/// Page to show [Room] data
class RoomDetailPage extends StatelessWidget {
  /// Creates new [RoomDetailPage]
  const new({
    required this.id,
    this.onRoomDeleted,
    super.key,
  });

  /// ID of the [Room] that will be shown
  final String id;

  /// Invoked when a [Room] has been deleted
  final void Function(Room)? onRoomDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<RoomDetailBloc>()
                ..add(RoomDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<RoomMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<FacultiesBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Ruangan'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return RoomDetail(
                onRoomDeleted: onRoomDeleted,
                onRetryPressed: () {
                  context.read<RoomDetailBloc>().add(
                    RoomDetailSubscriptionRequested(id: id),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
