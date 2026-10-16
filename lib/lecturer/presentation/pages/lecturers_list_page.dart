import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/pages/create_lecturer_page.dart';
import 'package:sistem_admin/lecturer/presentation/pages/lecturer_detail_page.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/widgets.dart';

/// Page to show lecturers data
class LecturersListPage extends StatelessWidget {
  /// Creates new [LecturersListPage]
  const new({
    this.onLecturerPressed,
    this.onCreatePressed,
    super.key,
  });

  /// Invoked when a lecturer is pressed
  final void Function(String lecturerId)? onLecturerPressed;

  /// Invoked when create button is pressed
  final void Function()? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<LecturersBloc>()..add(const LecturersSubscriptionRequested()),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Dosen'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: LecturersList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (lecturer) {
                  final lecturerId = lecturer.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (onLecturerPressed != null) {
                      onLecturerPressed?.call(lecturerId);
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        LecturerDetailCompactRoute(lecturerId)
                            .push<void>(context),
                      );
                    } else {
                      unawaited(
                        LecturerDetailRoute(lecturerId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = lecturerId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (onCreatePressed != null) {
                      onCreatePressed?.call();
                    } else if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateLecturerCompactRoute().push<void>(context),
                      );
                    } else {
                      unawaited(
                        const CreateLecturerRoute().push<void>(context),
                      );
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
          if (controller.data == 'create') {
            return const CreateLecturerPage();
          }
          return LecturerDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onLecturerDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
