import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/cohort/domain/domain.dart';
import 'package:sistem_admin/cohort/presentation/bloc/bloc.dart';
import 'package:sistem_admin/cohort/presentation/widgets/widgets.dart';
import 'package:sistem_admin/common/common.dart';

/// Page for creating new [Cohort]
class CreateCohortPage extends StatelessWidget {
  /// Creates new [CreateCohortPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CohortMutationBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Angkatan Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: CohortForm(),
        ),
      ),
    );
  }
}
