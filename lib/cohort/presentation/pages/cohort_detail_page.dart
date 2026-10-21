import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page to shows [Cohort] data
class CohortDetailPage extends StatelessWidget {
  /// Creates new [CohortDetailPage]
  const new({
    required this.id,
    this.onCohortDeleted,
    super.key,
  });

  /// ID of the [Cohort] that will be showed
  final String id;

  /// Invoked when a [Cohort] has been deleted
  final void Function(Cohort)? onCohortDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<CohortDetailBloc>()
                ..add(CohortDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<CohortMutationBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Angkatan'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return CohortDetail(
                onCohortDeleted: onCohortDeleted,
                onRetryPressed: () {
                  context.read<CohortDetailBloc>().add(
                    CohortDetailSubscriptionRequested(id: id),
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
