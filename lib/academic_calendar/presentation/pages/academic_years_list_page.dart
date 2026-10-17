import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/pages/academic_year_detail_page.dart';
import 'package:sistem_admin/academic_calendar/presentation/pages/create_academic_year_page.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page to show academic years data
class AcademicYearsListPage extends StatelessWidget {
  /// Creates new [AcademicYearsListPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AcademicYearsBloc>()
        ..add(
          const AcademicYearsSubscriptionRequested(),
        ),
      child: TwoPaneLayoutBuilder<String?>(
        initialAdditionalData: null,
        leftBuilder: (context, controller, breakPoint, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Tahun Akademik'),
            ),
            body: Padding(
              padding: AppSpacing.pagePadding,
              child: AcademicYearsList(
                selectedId: controller.data == 'create'
                    ? null
                    : controller.data,
                onPressed: (year) {
                  final yearId = year.id;
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        AcademicYearDetailCompactRoute(yearId)
                            .push<void>(context),
                      );
                    } else {
                      unawaited(
                        AcademicYearDetailRoute(yearId).push<void>(context),
                      );
                    }
                  } else {
                    controller.data = yearId;
                  }
                },
                onCreatePressed: () {
                  if (breakPoint < BreakPoint.expanded) {
                    if (breakPoint == BreakPoint.compact) {
                      unawaited(
                        const CreateAcademicYearCompactRoute().push<void>(
                          context,
                        ),
                      );
                    } else {
                      unawaited(
                        const CreateAcademicYearRoute().push<void>(context),
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
            return const CreateAcademicYearPage();
          }
          return AcademicYearDetailPage(
            key: ValueKey(controller.data!),
            id: controller.data!,
            onAcademicYearDeleted: (_) {
              controller.data = null;
            },
          );
        },
      ),
    );
  }
}
