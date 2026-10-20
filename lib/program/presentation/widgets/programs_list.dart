import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/widgets/program_list_tile.dart';

/// Shows list of [Program] data
class ProgramsList extends StatelessWidget {
  /// Creates new [ProgramsList]
  ///
  /// It reacts to [ProgramsBloc]'s state changes.
  /// So, make sure to provide it with that bloc.
  const new({
    this.onPressed,
    this.onCreatePressed,
    this.selectedId,
    super.key,
  });

  /// ID of selected program
  final String? selectedId;

  /// Invoked when one of programs is pressed
  final void Function(Program)? onPressed;

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
          child: BlocBuilder<ProgramsBloc, ProgramsState>(
            builder: (context, state) {
              switch (state) {
                case LoadingPrograms():
                case ProgramsInitial():
                  return const Center(
                    child: LoadingIndicator(size: 32),
                  );
                case ProgramsLoaded(:final data):
                  if (data.isEmpty) {
                    return const Center(
                      child: AppEmptyBox(
                        message: 'Belum ada data program studi',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, _) => const Divider(height: 4),
                    itemBuilder: (context, index) {
                      final program = data[index];
                      return ProgramListTile(
                        program: program,
                        selected: program.id == selectedId,
                        onPressed: onPressed == null
                            ? null
                            : () {
                                onPressed!(program);
                              },
                      );
                    },
                  );
                case ProgramsFailure(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal mengambil data program studi',
                      exception: exception,
                      onRetryPressed: () {
                        context.read<ProgramsBloc>().add(
                          const ProgramsSubscriptionRequested(),
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
