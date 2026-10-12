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

/// Branch for [Faculty] in [MainShell]
class FacultyMainShellData extends StatefulShellBranchData;

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
