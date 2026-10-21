part of 'app_router.dart';

/// Route for [CreateFacultyPage]
class CreateFacultyRoute extends GoRouteData with $CreateFacultyRoute {
  /// Creates new [CreateFacultyRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateFacultyPage();
}

/// Route for [CreateFacultyPage] in compact screen
class CreateFacultyCompactRoute extends GoRouteData
    with $CreateFacultyCompactRoute {
  /// Creates new [CreateFacultyRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateFacultyPage();
}

/// Route for [FacultiesListPage]
class FacultiesListRoute extends GoRouteData with $FacultiesListRoute {
  /// Creates new [FacultiesListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FacultiesListPage();
}

/// Route for [FacultyDetailPage]
class FacultyDetailRoute extends GoRouteData with $FacultyDetailRoute {
  /// Creates new [FacultyDetailRoute]
  const new(this.id);

  /// ID of the faculty that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => FacultyDetailPage(
    id: id,
    onFacultyDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [FacultyDetailPage] in compact screen
class FacultyDetailCompactRoute extends GoRouteData
    with $FacultyDetailCompactRoute {
  /// Creates new [FacultyDetailRoute]
  const new(this.id);

  /// ID of the faculty that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => FacultyDetailPage(
    id: id,
    onFacultyDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CreateProgramPage]
class CreateProgramRoute extends GoRouteData with $CreateProgramRoute {
  /// Creates new [CreateProgramRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateProgramPage();
}

/// Route for [CreateProgramPage] in compact screen
class CreateProgramCompactRoute extends GoRouteData
    with $CreateProgramCompactRoute {
  /// Creates new [CreateProgramRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateProgramPage();
}

/// Route for [ProgramsListPage]
class ProgramsListRoute extends GoRouteData with $ProgramsListRoute {
  /// Creates new [ProgramsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProgramsListPage();
}

/// Route for [ProgramDetailPage]
class ProgramDetailRoute extends GoRouteData with $ProgramDetailRoute {
  /// Creates new [ProgramDetailRoute]
  const new(this.id);

  /// ID of the program that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProgramDetailPage(
    id: id,
    onProgramDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [ProgramDetailPage] in compact screen
class ProgramDetailCompactRoute extends GoRouteData
    with $ProgramDetailCompactRoute {
  /// Creates new [ProgramDetailRoute]
  const new(this.id);

  /// ID of the program that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProgramDetailPage(
    id: id,
    onProgramDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CreateLecturerPage]
class CreateLecturerRoute extends GoRouteData with $CreateLecturerRoute {
  /// Creates new [CreateLecturerRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateLecturerPage();
}

/// Route for [CreateLecturerPage] in compact screen
class CreateLecturerCompactRoute extends GoRouteData
    with $CreateLecturerCompactRoute {
  /// Creates new [CreateLecturerRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateLecturerPage();
}

/// Route for [LecturersListPage]
class LecturersListRoute extends GoRouteData with $LecturersListRoute {
  /// Creates new [LecturersListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LecturersListPage();
}

/// Route for [LecturerDetailPage]
class LecturerDetailRoute extends GoRouteData with $LecturerDetailRoute {
  /// Creates new [LecturerDetailRoute]
  const new(this.id);

  /// ID of the lecturer that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => LecturerDetailPage(
    id: id,
    onLecturerDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [LecturerDetailPage] in compact screen
class LecturerDetailCompactRoute extends GoRouteData
    with $LecturerDetailCompactRoute {
  /// Creates new [LecturerDetailRoute]
  const new(this.id);

  /// ID of the lecturer that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => LecturerDetailPage(
    id: id,
    onLecturerDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CreateCoursePage]
class CreateCourseRoute extends GoRouteData with $CreateCourseRoute {
  /// Creates new [CreateCourseRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateCoursePage();
}

/// Route for [CreateCoursePage] in compact screen
class CreateCourseCompactRoute extends GoRouteData
    with $CreateCourseCompactRoute {
  /// Creates new [CreateCourseRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateCoursePage();
}

/// Route for [CoursesListPage]
class CoursesListRoute extends GoRouteData with $CoursesListRoute {
  /// Creates new [CoursesListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CoursesListPage();
}

/// Route for [CourseDetailPage]
class CourseDetailRoute extends GoRouteData with $CourseDetailRoute {
  /// Creates new [CourseDetailRoute]
  const new(this.id);

  /// ID of the course that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => CourseDetailPage(
    id: id,
    onCourseDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CourseDetailPage] in compact screen
class CourseDetailCompactRoute extends GoRouteData
    with $CourseDetailCompactRoute {
  /// Creates new [CourseDetailRoute]
  const new(this.id);

  /// ID of the course that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => CourseDetailPage(
    id: id,
    onCourseDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CreateRoomPage]
class CreateRoomRoute extends GoRouteData with $CreateRoomRoute {
  /// Creates new [CreateRoomRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateRoomPage();
}

/// Route for [CreateRoomPage] in compact screen
class CreateRoomCompactRoute extends GoRouteData with $CreateRoomCompactRoute {
  /// Creates new [CreateRoomRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateRoomPage();
}

/// Route for [RoomsListPage]
class RoomsListRoute extends GoRouteData with $RoomsListRoute {
  /// Creates new [RoomsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoomsListPage();
}

/// Route for [RoomDetailPage]
class RoomDetailRoute extends GoRouteData with $RoomDetailRoute {
  /// Creates new [RoomDetailRoute]
  const new(this.id);

  /// ID of the room that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => RoomDetailPage(
    id: id,
    onRoomDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [RoomDetailPage] in compact screen
class RoomDetailCompactRoute extends GoRouteData with $RoomDetailCompactRoute {
  /// Creates new [RoomDetailRoute]
  const new(this.id);

  /// ID of the room that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => RoomDetailPage(
    id: id,
    onRoomDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CreateAcademicYearPage]
class CreateAcademicYearRoute extends GoRouteData
    with $CreateAcademicYearRoute {
  /// Creates new [CreateAcademicYearRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateAcademicYearPage();
}

/// Route for [CreateAcademicYearPage] in compact screen
class CreateAcademicYearCompactRoute extends GoRouteData
    with $CreateAcademicYearCompactRoute {
  /// Creates new [CreateAcademicYearRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateAcademicYearPage();
}

/// Route for [AcademicYearsListPage]
class AcademicYearsListRoute extends GoRouteData with $AcademicYearsListRoute {
  /// Creates new [AcademicYearsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AcademicYearsListPage();
}

/// Route for [AcademicYearDetailPage]
class AcademicYearDetailRoute extends GoRouteData
    with $AcademicYearDetailRoute {
  /// Creates new [AcademicYearDetailRoute]
  const new(this.id);

  /// ID of the academic year that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AcademicYearDetailPage(
        id: id,
        onAcademicYearDeleted: (_) {
          context.pop();
        },
      );
}

/// Route for [AcademicYearDetailPage] in compact screen
class AcademicYearDetailCompactRoute extends GoRouteData
    with $AcademicYearDetailCompactRoute {
  /// Creates new [AcademicYearDetailRoute]
  const new(this.id);

  /// ID of the academic year that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AcademicYearDetailPage(
        id: id,
        onAcademicYearDeleted: (_) {
          context.pop();
        },
      );
}

/// Route for [CreateCohortPage]
class CreateCohortRoute extends GoRouteData with $CreateCohortRoute {
  /// Creates new [CreateCohortRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateCohortPage();
}

/// Route for [CreateCohortPage] in compact screen
class CreateCohortCompactRoute extends GoRouteData
    with $CreateCohortCompactRoute {
  /// Creates new [CreateCohortCompactRoute]
  const new();

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateCohortPage();
}

/// Route for [CohortsListPage]
class CohortsListRoute extends GoRouteData with $CohortsListRoute {
  /// Creates new [CohortsListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CohortsListPage();
}

/// Route for [CohortDetailPage]
class CohortDetailRoute extends GoRouteData with $CohortDetailRoute {
  /// Creates new [CohortDetailRoute]
  const new(this.id);

  /// ID of the cohort that will be loaded
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => CohortDetailPage(
    id: id,
    onCohortDeleted: (_) {
      context.pop();
    },
  );
}

/// Route for [CohortDetailPage] in compact screen
class CohortDetailCompactRoute extends GoRouteData
    with $CohortDetailCompactRoute {
  /// Creates new [CohortDetailCompactRoute]
  const new(this.id);

  /// ID of the cohort that will be loaded
  final String id;

  /// Parent navigator for this route
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavKey;

  @override
  Widget build(BuildContext context, GoRouterState state) => CohortDetailPage(
    id: id,
    onCohortDeleted: (_) {
      context.pop();
    },
  );
}

/// Branch for [Faculty] in [MainShell]
class FacultyMainShellData extends StatefulShellBranchData;

/// Branch for [Program] in [MainShell]
class ProgramMainShellData extends StatefulShellBranchData;

/// Branch for [Lecturer] in [MainShell]
class LecturerMainShellData extends StatefulShellBranchData;

/// Branch for [Course] in [MainShell]
class CourseMainShellData extends StatefulShellBranchData;

/// Branch for [Room] in [MainShell]
class RoomMainShellData extends StatefulShellBranchData;

/// Branch for [AcademicYear] in [MainShell]
class AcademicCalendarMainShellData extends StatefulShellBranchData;

/// Branch for [Cohort] in [MainShell]
class CohortMainShellData extends StatefulShellBranchData;

/// Route for [MainShell]
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<FacultyMainShellData>(
      routes: [
        TypedGoRoute<FacultiesListRoute>(
          path: '/faculties',
          routes: [
            TypedGoRoute<CreateFacultyRoute>(path: 'create'),
            TypedGoRoute<CreateFacultyCompactRoute>(path: 'create-compact'),
            TypedGoRoute<FacultyDetailRoute>(path: ':id'),
            TypedGoRoute<FacultyDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ProgramMainShellData>(
      routes: [
        TypedGoRoute<ProgramsListRoute>(
          path: '/programs',
          routes: [
            TypedGoRoute<CreateProgramRoute>(path: 'create'),
            TypedGoRoute<CreateProgramCompactRoute>(path: 'create-compact'),
            TypedGoRoute<ProgramDetailRoute>(path: ':id'),
            TypedGoRoute<ProgramDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<LecturerMainShellData>(
      routes: [
        TypedGoRoute<LecturersListRoute>(
          path: '/lecturers',
          routes: [
            TypedGoRoute<CreateLecturerRoute>(path: 'create'),
            TypedGoRoute<CreateLecturerCompactRoute>(path: 'create-compact'),
            TypedGoRoute<LecturerDetailRoute>(path: ':id'),
            TypedGoRoute<LecturerDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CourseMainShellData>(
      routes: [
        TypedGoRoute<CoursesListRoute>(
          path: '/courses',
          routes: [
            TypedGoRoute<CreateCourseRoute>(path: 'create'),
            TypedGoRoute<CreateCourseCompactRoute>(path: 'create-compact'),
            TypedGoRoute<CourseDetailRoute>(path: ':id'),
            TypedGoRoute<CourseDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<RoomMainShellData>(
      routes: [
        TypedGoRoute<RoomsListRoute>(
          path: '/rooms',
          routes: [
            TypedGoRoute<CreateRoomRoute>(path: 'create'),
            TypedGoRoute<CreateRoomCompactRoute>(path: 'create-compact'),
            TypedGoRoute<RoomDetailRoute>(path: ':id'),
            TypedGoRoute<RoomDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<AcademicCalendarMainShellData>(
      routes: [
        TypedGoRoute<AcademicYearsListRoute>(
          path: '/academic-calendar',
          routes: [
            TypedGoRoute<CreateAcademicYearRoute>(path: 'create'),
            TypedGoRoute<CreateAcademicYearCompactRoute>(
              path: 'create-compact',
            ),
            TypedGoRoute<AcademicYearDetailRoute>(path: ':id'),
            TypedGoRoute<AcademicYearDetailCompactRoute>(
              path: 'compact/:id',
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CohortMainShellData>(
      routes: [
        TypedGoRoute<CohortsListRoute>(
          path: '/cohorts',
          routes: [
            TypedGoRoute<CreateCohortRoute>(path: 'create'),
            TypedGoRoute<CreateCohortCompactRoute>(path: 'create-compact'),
            TypedGoRoute<CohortDetailRoute>(path: ':id'),
            TypedGoRoute<CohortDetailCompactRoute>(path: 'compact/:id'),
          ],
        ),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(
      currentIndex: navigationShell.currentIndex,
      onDestinationChanged: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      child: navigationShell,
    );
  }
}
