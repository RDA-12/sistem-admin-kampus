import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/pages/create_program_page.dart';
import 'package:sistem_admin/program/presentation/pages/program_detail_page.dart';
import 'package:sistem_admin/program/presentation/widgets/widgets.dart';

/// Page to show programs data
class ProgramsListPage extends StatelessWidget {
  /// Creates new [ProgramsListPage]
  const new({
    this.onProgramPressed,
    this.onCreatePressed,
    super.key,
  });

  /// Invoked when a program is pressed
  final void Function(String programId)? onProgramPressed;

  /// Invoked when create button is pressed
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ProgramsBloc>()..add(const ProgramsSubscriptionRequested()),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Program Studi'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: ProgramsList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (program) {
                  final programId = program.id;
                  if (breakPoint < BreakPoint.expanded) {
                    onProgramPressed?.call(programId);
                  } else {
                    controller.data = programId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    onCreatePressed?.call();
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
          if (controller.data == 'create') {
            return const CreateProgramPage();
          }
          return ProgramDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onProgramDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
