import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/room/domain/domain.dart';
import 'package:sistem_admin/room/presentation/bloc/bloc.dart';
import 'package:sistem_admin/room/presentation/widgets/widgets.dart';

/// Page for creating new [Room]
class CreateRoomPage extends StatelessWidget {
  /// Creates new [CreateRoomPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<RoomMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<FacultiesBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Ruangan Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: RoomForm(),
        ),
      ),
    );
  }
}
