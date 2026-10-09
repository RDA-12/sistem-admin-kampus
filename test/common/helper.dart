import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/core/core.dart';

extension WidgetTesterX on WidgetTester {
  Future<void> pumpWidgetForTest(Widget Function(BuildContext) builder) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: builder),
        ),
      ),
    );
  }

  /// Pump [MaterialApp.router] with pre-configured router.
  ///
  /// [page] will be at route [path].
  ///
  /// The router config will be at [path] initially.
  ///
  /// [additionalRoutes] typically used to test moving from [page] to others.
  /// Ensure the `others` are within [additionalRoutes].
  Future<void> pumpPageForTest({
    required Widget page,
    List<GoRoute> additionalRoutes = const [],
    String path = '/',
  }) {
    final routes = [
      GoRoute(
        path: path,
        builder: (context, state) => page,
      ),
      ...additionalRoutes,
    ];

    return pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: path,
          routes: routes,
        ),
      ),
    );
  }
}

/// Helper for [AppResult] expectation
extension AppResultX<T> on AppResult<T> {
  void expectFailureWithCode(AppExceptionCode code) => expect(
    this,
    isA<AppFailure<T>>().having(
      (e) => e.exception.code,
      'exception.code',
      code,
    ),
  );
}
