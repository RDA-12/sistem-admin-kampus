import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/domain/domain.dart';
import 'package:sistem_admin/course/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course/presentation/widgets/widgets.dart';
import 'package:sistem_admin/program/program.dart';

/// Page for creating new [Course]
class CreateCoursePage extends StatelessWidget {
  /// Creates new [CreateCoursePage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<CourseMutationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProgramsBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Mata Kuliah Baru'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: CourseForm(),
        ),
      ),
    );
  }
}
