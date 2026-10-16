import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/shell/shell.dart';
import 'package:sistem_admin/course/course.dart';
import 'package:sistem_admin/faculty/faculty.dart';
import 'package:sistem_admin/lecturer/lecturer.dart';
import 'package:sistem_admin/program/program.dart';
import 'package:sistem_admin/room/room.dart';

part 'app_routes.dart';
part 'app_router.g.dart';

/// Navigator key for root app
final rootNavKey = GlobalKey<NavigatorState>();

/// Holds router for this app
class AppRouter {
  /// Router config for this app
  static GoRouter config = GoRouter(
    navigatorKey: rootNavKey,
    initialLocation: '/faculties',
    routes: $appRoutes,
  );
}
