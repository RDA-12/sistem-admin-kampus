import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/domain.dart';
import 'package:sistem_admin/faculty/presentation/bloc/bloc.dart';
import 'package:sistem_admin/faculty/presentation/widgets/widgets.dart';

/// Page for creating new [Faculty]
class CreateFacultyPage extends StatelessWidget {
  /// Creates new [CreateFacultyPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FacultyMutationBloc>(),
      child: const Scaffold(
        body: Padding(
          padding: AppSpacing.pagePadding,
          child: FacultyForm(),
        ),
      ),
    );
  }
}
