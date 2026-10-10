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
@TypedGoRoute<FacultiesListRoute>(
  path: '/faculties',
  routes: [
    TypedGoRoute<CreateFacultyRoute>(path: 'create'),
  ],
)
class FacultiesListRoute extends GoRouteData with $FacultiesListRoute {
  /// Creates new [FacultiesListRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FacultiesListPage();
}
