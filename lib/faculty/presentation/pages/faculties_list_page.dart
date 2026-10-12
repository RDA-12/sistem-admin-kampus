import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/pages/create_faculty_page.dart';
import 'package:sistem_admin/faculty/presentation/pages/faculty_detail_page.dart';
import 'package:sistem_admin/faculty/presentation/widgets/widgets.dart';

/// Page to shows faculties data
class FacultiesListPage extends StatelessWidget {
  /// Creates new [FacultiesListPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FacultiesBloc>()
        ..add(
          const FacultiesSubscriptionRequested(),
        ),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Fakultas'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: FacultiesList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (faculty) {
                  final facultyId = faculty.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        FacultyDetailCompactRoute(facultyId)
                            .push<void>(context),
                      );
                    } else {
                      unawaited(
                        FacultyDetailRoute(facultyId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = facultyId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateFacultyCompactRoute().push<void>(context),
                      );
                    } else {
                      unawaited(const CreateFacultyRoute().push<void>(context));
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
          if (controller.data == 'create') return const CreateFacultyPage();
          return FacultyDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
          );
        },
      ),
    );
  }
}
