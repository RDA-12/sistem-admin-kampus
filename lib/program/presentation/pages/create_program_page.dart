import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/program/domain/domain.dart';
import 'package:sistem_admin/program/presentation/bloc/bloc.dart';
import 'package:sistem_admin/program/presentation/widgets/widgets.dart';

/// Page for creating new [Program]
class CreateProgramPage extends StatelessWidget {
  /// Creates new [CreateProgramPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProgramMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<FacultiesBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Program Studi Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: ProgramForm(),
        ),
      ),
    );
  }
}
