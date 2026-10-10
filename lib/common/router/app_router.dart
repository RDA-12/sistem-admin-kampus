import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/faculty/faculty.dart';

part 'app_routes.dart';
part 'app_router.g.dart';

/// Holds router for this app
class AppRouter {
  /// Router config for this app
  static GoRouter config = GoRouter(
    initialLocation: '/faculties',
    routes: $appRoutes,
  );
}
