import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/lecturer_list_tile.dart';

/// Shows list of [Lecturer] data
class LecturersList extends StatelessWidget {
  /// Creates new [LecturersList]
  ///
  /// It reacts to [LecturersBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected lecturer
  final String? selectedId;

  /// Invoked when one of lecturers is pressed
  final void Function(Lecturer)? onPressed;

  /// Invoked when user press create button
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
          child: BlocBuilder<LecturersBloc, LecturersState>(
            builder: (context, state) {
              switch (state) {
                case LoadingLecturers():
                case LecturersInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case LecturersLoaded(:final data):
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final lecturer = data[index];
                      return LecturerListTile(
                        lecturer: lecturer,
                        selected: lecturer.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(lecturer);
                              },
                      );
                    },
                  );
                case LecturersFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data dosen',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<LecturersBloc>().add(
                          const LecturersSubscriptionRequested(),
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
