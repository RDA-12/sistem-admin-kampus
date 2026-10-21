import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/pages/cohort_detail_page.dart';
import 'package:sistem_admin/cohort/presentation/pages/create_cohort_page.dart';
import 'package:sistem_admin/cohort/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page to shows cohorts data
class CohortsListPage extends StatelessWidget {
  /// Creates new [CohortsListPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CohortsBloc>()
        ..add(
          const CohortsSubscriptionRequested(),
        ),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Angkatan'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: CohortsList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (cohort) {
                  final cohortId = cohort.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        CohortDetailCompactRoute(cohortId).push<void>(context),
                      );
                    } else {
                      unawaited(
                        CohortDetailRoute(cohortId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = cohortId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateCohortCompactRoute().push<void>(context),
                      );
                    } else {
                      unawaited(const CreateCohortRoute().push<void>(context));
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
          if (controller.data == 'create') return const CreateCohortPage();
          return CohortDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onCohortDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
