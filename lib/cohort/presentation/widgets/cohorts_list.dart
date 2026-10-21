import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/widgets/cohort_list_tile.dart';
import 'package:sistem_admin/common/common.dart';

/// Shows list of [Cohort] data
class CohortsList extends StatelessWidget {
  /// Creates new [CohortsList]
  ///
  /// It reacts to [CohortsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected cohort
  final String? selectedId;

  /// Invoked when one of cohorts is pressed
  final void Function(Cohort)? onPressed;

  /// Invoked when user presses create button
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          mainAxisAlignment: .end,
          children: [
            AppButton(
              label: 'Buat baru',
              onPressed: onCreatePressed,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<CohortsBloc, CohortsState>(
            builder: (context, state) {
              switch (state) {
                case LoadingCohorts():
                case CohortsInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case CohortsLoaded(:final data):
                  if (data.isEmpty) {
                    return const Center(
                      child: AppEmptyBox(
                        message: 'Belum ada data angkatan',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final cohort = data[index];
                      return CohortListTile(
                        cohort: cohort,
                        selected: cohort.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(cohort);
                              },
                      );
                    },
                  );
                case CohortsFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data angkatan',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<CohortsBloc>().add(
                          const CohortsSubscriptionRequested(),
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
