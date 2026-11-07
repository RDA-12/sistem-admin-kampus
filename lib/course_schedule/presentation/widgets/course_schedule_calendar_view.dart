import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/presentation/bloc/bloc.dart';
import 'package:sistem_admin/course_schedule/presentation/widgets/course_schedule_calendar.dart';
import 'package:sistem_admin/program/program.dart';

/// Shows calendar showing course schedules on it
class CourseScheduleCalendarView extends StatefulWidget {
  /// Creates new [CourseScheduleCalendarView]
  ///
  /// It reacts to [CourseSchedulesBloc]'s state changes. Ensure to provide
  /// that within the widget tree
  const new({super.key});

  @override
  State<CourseScheduleCalendarView> createState() =>
      _CourseScheduleCalendarViewState();
}

class _CourseScheduleCalendarViewState
    extends State<CourseScheduleCalendarView> {
  late final ProgramSelectorController _programSelectorController;
  late final AcademicYearSelectorController _yearSelectorController;
  late final AcademicTermSelectorController _termSelectorController;

  @override
  void initState() {
    super.initState();
    _programSelectorController = ProgramSelectorController()
      ..addListener(_onFilterChanged);
    _yearSelectorController = AcademicYearSelectorController()
      ..addListener(_onFilterChanged);
    _termSelectorController = AcademicTermSelectorController()
      ..addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _programSelectorController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _yearSelectorController
      ..removeListener(_onFilterChanged)
      ..dispose();
    _termSelectorController
      ..removeListener(_onFilterChanged)
      ..dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    final programId = _programSelectorController.selected?.id;
    final yearId = _yearSelectorController.selected?.id;
    final termId = _termSelectorController.selected?.id;
    if (programId == null || yearId == null || termId == null) {
      return;
    }
    context.read<CourseSchedulesBloc>().add(
      CourseSchedulesSubscriptionRequested(
        academicYearId: yearId,
        termId: termId,
        programId: programId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: ProgramSelector(
                label: 'Program Studi',
                controller: _programSelectorController,
              ),
            ),
            Expanded(
              child: AcademicYearSelector(
                label: 'Tahun Akademik',
                controller: _yearSelectorController,
              ),
            ),
            Expanded(
              child: AcademicTermSelector(
                label: 'Semester',
                controller: _termSelectorController,
              ),
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<CourseSchedulesBloc, CourseSchedulesState>(
            builder: (context, state) {
              switch (state) {
                case CourseSchedulesInitial():
                  return const Center(
                    child: AppEmptyBox(
                      message:
                          'Pilih Program Studi, Tahun Akademik, dan Semester '
                          'untuk melihat jadwal perkuliahan '
                          'program studi yang dipilih',
                    ),
                  );
                case CourseSchedulesLoadData():
                  return const Center(
                    child: LoadingIndicator(),
                  );
                case CourseSchedulesLoadFailed(:final exception):
                  return Center(
                    child: AppExceptionBox(
                      title: 'Gagal memuat jadwal kuliah',
                      exception: exception,
                    ),
                  );
                case CourseSchedulesLoaded(:final calendar):
                  if (calendar.schedules.isEmpty) {
                    return const Center(
                      child: AppEmptyBox(
                        message: 'Tidak ada jadwal yang tersimpan',
                      ),
                    );
                  }
                  return CourseScheduleCalendar(
                    calendar: calendar,
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
