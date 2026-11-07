import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course_schedule/presentation/widgets/widgets.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

/// Page to shows course schedules
class CourseSchedulePage extends StatelessWidget {
  /// Creates new [CourseSchedulePage]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<CourseSchedulesBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<CourseScheduleMutationBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              getIt<ProgramsBloc>()..add(const ProgramsSubscriptionRequested()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<AcademicYearsBloc>()
                ..add(const AcademicYearsSubscriptionRequested()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<AcademicTermsBloc>()
                ..add(const AcademicTermsSubscriptionRequested()),
        ),
        BlocProvider(
          create: (context) => getIt<CohortsBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<CoursesBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<LecturersBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<RoomsBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Perkuliahan'),
        ),
        body: const Padding(
          padding: AppSpacing.pagePadding,
          child: CourseScheduleCalendarView(),
        ),
      ),
    );
  }
}
