part of 'app_router.dart';

/// Route for [CreateFacultyPage]
class CreateFacultyRoute extends GoRouteData with $CreateFacultyRoute {
  /// Creates new [CreateFacultyRoute]
  const new();

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
