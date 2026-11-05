import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sistem_admin/academic_calendar/academic_calendar.dart';
import 'package:sistem_admin/cohort/cohort.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/course_schedule/domain/domain.dart';
import 'package:sistem_admin/course_schedule/presentation/models.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/room/room.dart';

part 'course_schedules_event.dart';
part 'course_schedules_state.dart';

/// Bloc to read course schedules
@injectable
class CourseSchedulesBloc
    extends Bloc<CourseSchedulesEvent, CourseSchedulesState>
    with AppLoggerMixin {
  /// Creates new [CourseSchedulesBloc]
  new({
    required this._watchSingleAcademicYear,
    required this._watchCourseSchedules,
    required this._watchCohorts,
    required this._watchCourses,
    required this._watchLecturers,
    required this._watchRooms,
  }) : super(const CourseSchedulesInitial()) {
    on<CourseSchedulesSubscriptionRequested>(
      _onCourseSchedulesSubscriptionRequested,
      transformer: restartable(),
    );
  }

  final WatchSingleAcademicYearUseCase _watchSingleAcademicYear;
  final WatchCourseSchedulesUseCase _watchCourseSchedules;
  final WatchCohortsUseCase _watchCohorts;
  final WatchCoursesUseCase _watchCourses;
  final WatchLecturersUseCase _watchLecturers;
  final WatchRoomsUseCase _watchRooms;

  Future<void> _onCourseSchedulesSubscriptionRequested(
    CourseSchedulesSubscriptionRequested event,
    Emitter<CourseSchedulesState> emit,
  ) async {
    await AppLogger.runWithLogger(() async {
      logDebug(
        'starts subscribe to course schedules changes. emits loading',
        extra: {
          'academicYearId': event.academicYearId,
          'termId': event.termId,
          'programId': event.programId,
        },
      );
      emit(const CourseSchedulesLoadData());

      final stream = CombineLatestStream.combine6(
        _watchSingleAcademicYear(event.academicYearId),
        _watchCourseSchedules(
          CourseScheduleFilter(
            academicYearId: event.academicYearId,
            termId: event.termId,
            programId: event.programId,
          ),
        ),
        _watchCohorts(null),
        _watchCourses(CourseFilter(programId: event.programId)),
        _watchLecturers(),
        _watchRooms(),
        (
          academicYearResult,
          schedulesResult,
          cohortsResult,
          coursesResult,
          lecturersResult,
          roomsResult,
        ) {
          late final AcademicYear academicYear;
          switch (academicYearResult) {
            case AppFailure<AcademicYear>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<AcademicYear>(:final data):
              academicYear = data;
          }

          late final List<CourseSchedule> schedules;
          switch (schedulesResult) {
            case AppFailure<List<CourseSchedule>>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<List<CourseSchedule>>(:final data):
              schedules = data;
          }

          late final List<Cohort> cohorts;
          switch (cohortsResult) {
            case AppFailure<List<Cohort>>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<List<Cohort>>(:final data):
              cohorts = data;
          }

          late final List<Course> courses;
          switch (coursesResult) {
            case AppFailure<List<Course>>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<List<Course>>(:final data):
              courses = data;
          }

          late final List<Lecturer> lecturers;
          switch (lecturersResult) {
            case AppFailure<List<Lecturer>>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<List<Lecturer>>(:final data):
              lecturers = data;
          }

          late final List<Room> rooms;
          switch (roomsResult) {
            case AppFailure<List<Room>>(:final exception):
              return AppResult<CourseScheduleCalendarUI>.failure(exception);
            case AppSuccess<List<Room>>(:final data):
              rooms = data;
          }

          final scheduleUIs = <CourseScheduleUI>[];
          for (final schedule in schedules) {
            if (schedule.academicYearId != event.academicYearId ||
                schedule.termId != event.termId ||
                schedule.programId != event.programId) {
              continue;
            }

            final cohort = cohorts.firstWhereOrNull(
              (it) => it.id == schedule.cohortId,
            );
            final course = courses.firstWhereOrNull(
              (it) => it.id == schedule.courseId,
            );
            final lecturer = lecturers.firstWhereOrNull(
              (it) => it.id == schedule.lecturerId,
            );
            final room = rooms.firstWhereOrNull(
              (it) => it.id == schedule.roomId,
            );

            if (cohort == null ||
                course == null ||
                lecturer == null ||
                room == null) {
              continue;
            }

            scheduleUIs.add(
              CourseScheduleUI(
                id: schedule.id,
                academicYearId: schedule.academicYearId,
                termId: schedule.termId,
                name: schedule.name,
                start: schedule.start,
                duration: schedule.duration,
                cohortId: schedule.cohortId,
                courseId: schedule.courseId,
                programId: schedule.programId,
                lecturerId: schedule.lecturerId,
                roomId: schedule.roomId,
                cohort: cohort,
                course: course,
                lecturer: lecturer,
                room: room,
              ),
            );
          }

          return AppResult.success(
            CourseScheduleCalendarUI(
              academicCalendar: AcademicCalendar(year: academicYear),
              schedules: scheduleUIs,
            ),
          );
        },
      );

      await emit.forEach(
        stream,
        onData: (result) {
          switch (result) {
            case AppSuccess(:final data):
              logDebug('new course schedules received. emit loaded');
              return CourseSchedulesLoaded(data);
            case AppFailure(:final exception):
              logDebug('failure result received. emit failure');
              return CourseSchedulesLoadFailed(exception);
          }
        },
      );
    });
  }
}
