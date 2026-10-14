import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/widgets/widgets.dart';

/// Page to show [Program] data
class ProgramDetailPage extends StatelessWidget {
  /// Creates new [ProgramDetailPage]
  const new({
    required this.id,
    this.onProgramDeleted,
    super.key,
  });

  /// ID of the [Program] that will be shown
  final String id;

  /// Invoked when a [Program] has been deleted
  final void Function(Program)? onProgramDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<ProgramDetailBloc>()
                ..add(ProgramDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<ProgramMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<FacultiesBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Program Studi'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return ProgramDetail(
                onProgramDeleted: onProgramDeleted,
                onRetryPressed: () {
                  context.read<ProgramDetailBloc>().add(
                    ProgramDetailSubscriptionRequested(id: id),
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
