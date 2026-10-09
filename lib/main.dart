import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

void main() {
  runApp(const MainApp());
}

/// Main widget for the app
class MainApp extends StatelessWidget {
  /// Creates new [MainApp]
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.config,
    );
  }
}
