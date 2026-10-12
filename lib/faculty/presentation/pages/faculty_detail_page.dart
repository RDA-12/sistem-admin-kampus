import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/widgets.dart';

/// Page to shows [Faculty] data
class FacultyDetailPage extends StatelessWidget {
  /// Creates new [FacultyDetailPage]
  const new({
    required this.id,
    super.key,
  });

  /// ID of the [Faculty] that will be showed
  final String id;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<FacultyDetailBloc>()
                ..add(FacultyDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<FacultyMutationBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Fakultas'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return FacultyDetail(
                onRetryPressed: () {
                  context.read<FacultyDetailBloc>().add(
                    FacultyDetailSubscriptionRequested(id: id),
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
