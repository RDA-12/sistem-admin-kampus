import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page to show [AcademicYear] data
class AcademicYearDetailPage extends StatelessWidget {
  /// Creates new [AcademicYearDetailPage]
  const new({
    required this.id,
    this.onAcademicYearDeleted,
    super.key,
  });

  /// ID of the [AcademicYear] that will be shown
  final String id;

  /// Invoked when an [AcademicYear] has been deleted
  final void Function(AcademicYear)? onAcademicYearDeleted;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<AcademicYearDetailBloc>()
                ..add(AcademicYearDetailSubscriptionRequested(id: id)),
        ),
        BlocProvider(
          create: (context) => getIt<AcademicYearMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<AcademicTermMutationBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Tahun Akademik'),
        ),
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: Builder(
            builder: (context) {
              return AcademicYearDetail(
                onAcademicYearDeleted: onAcademicYearDeleted,
                onRetryPressed: () {
                  context.read<AcademicYearDetailBloc>().add(
                    AcademicYearDetailSubscriptionRequested(id: id),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
