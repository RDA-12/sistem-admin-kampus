import 'package:google_fonts/google_fonts.dart';
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
    final textTheme = GoogleFonts.googleSansTextTheme();
    final theme = AppTheme(textTheme);

    return MaterialApp.router(
      routerConfig: AppRouter.config,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: ThemeMode.light,
    );
  }
}
