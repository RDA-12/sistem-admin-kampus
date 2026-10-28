import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/domain/domain.dart';
import 'package:sistem_admin/academic_calendar/presentation/bloc/bloc.dart';
import 'package:sistem_admin/academic_calendar/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page for creating new [AcademicYear]
class CreateAcademicYearPage extends StatelessWidget {
  /// Creates new [CreateAcademicYearPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AcademicCalendarMutationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Tahun Akademik Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: AcademicYearForm(),
        ),
      ),
    );
  }
}
