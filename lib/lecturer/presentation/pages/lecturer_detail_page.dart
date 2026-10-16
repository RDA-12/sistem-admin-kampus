import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/widgets.dart';
import 'package:sistem_admin/program/program.dart';

/// Page to show [Lecturer] data
class LecturerDetailPage extends StatelessWidget {
  /// Creates new [LecturerDetailPage]
  const new({
    required this.id,
    this.onLecturerDeleted,
    super.key,
  });

  /// ID of the [Lecturer] that will be shown
  final String id;

  /// Invoked when a [Lecturer] has been deleted
  final void Function(Lecturer)? onLecturerDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<LecturerDetailBloc>()
                ..add(LecturerDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<LecturerMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProgramsBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Dosen'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return LecturerDetail(
                onLecturerDeleted: onLecturerDeleted,
                onRetryPressed: () {
                  context.read<LecturerDetailBloc>().add(
                    LecturerDetailSubscriptionRequested(id: id),
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
