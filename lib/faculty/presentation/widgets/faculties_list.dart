import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/faculty_list_tile.dart';

/// Shows list of [Faculty] data
class FacultiesList extends StatelessWidget {
  /// Creates new [FacultiesList]
  ///
  /// It reacts to [FacultiesBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected faculty
  final String? selectedId;

  /// Invoked when one of faculties is pressed
  final void Function(Faculty)? onPressed;

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
          child: BlocBuilder<FacultiesBloc, FacultiesState>(
            builder: (context, state) {
              switch (state) {
                case LoadingFaculties():
                case FacultiesInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case FacultiesLoaded(:final data):
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final faculty = data[index];
                      return FacultyListTile(
                        faculty: faculty,
                        selected: faculty.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(faculty);
                              },
                      );
                    },
                  );
                case FacultiesFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data fakultas',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<FacultiesBloc>().add(
                          const FacultiesSubscriptionRequested(),
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
