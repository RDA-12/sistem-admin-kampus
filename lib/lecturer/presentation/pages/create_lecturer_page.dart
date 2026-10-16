import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/domain.dart';
import 'package:sistem_admin/lecturer/presentation/bloc/bloc.dart';
import 'package:sistem_admin/lecturer/presentation/widgets/widgets.dart';
import 'package:sistem_admin/program/program.dart';

/// Page for creating new [Lecturer]
class CreateLecturerPage extends StatelessWidget {
  /// Creates new [CreateLecturerPage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<LecturerMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProgramsBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Dosen Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: LecturerForm(),
        ),
      ),
    );
  }
}
