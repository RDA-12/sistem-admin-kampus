part of 'app_router.dart';

/// Route for [CreateFacultyPage]
@TypedGoRoute<CreateFacultyRoute>(path: '/create')
class CreateFacultyRoute extends GoRouteData with $CreateFacultyRoute {
  /// Creates new [CreateFacultyRoute]
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateFacultyPage();
}
