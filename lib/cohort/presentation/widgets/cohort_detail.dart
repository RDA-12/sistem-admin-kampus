import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/widgets/cohort_form.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows detail of a cohort
class CohortDetail extends StatelessWidget {
  /// Creates new [CohortDetail]
  ///
  /// It reacts to [CohortDetailBloc] and [CohortMutationBloc] state changes.
  /// So, ensure to provide it with those blocs.
  const new({
    this.onRetryPressed,
    this.onCohortDeleted,
    super.key,
  });

  /// Invoked when user presses retry button
  final void Function()? onRetryPressed;

  /// Invoked when a cohort has been deleted
  final void Function(Cohort)? onCohortDeleted;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CohortDetailBloc, CohortDetailState>(
      builder: (context, state) {
        switch (state) {
          case CohortDetailInitial():
          case LoadingCohortDetail():
            return const Center(
              child: LoadingIndicator(),
            );
          case CohortDetailLoaded(:final cohort):
            return CohortForm(
              initial: cohort,
              onCohortDeleted: onCohortDeleted,
            );
          case CohortDetailLoadFailed(:final exception):
            return Center(
              child: AppExceptionBox(
                title: 'Gagal mengambil data angkatan',
                exception: exception,
                onRetryPressed: onRetryPressed,
              ),
            );
        }
      },
    );
  }
}
