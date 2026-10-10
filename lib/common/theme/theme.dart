import 'package:material_ui/material_ui.dart';

/// Theme for this app
class AppTheme {
  /// Creates new [AppTheme]
  const new(this.textTheme);

  /// Text theme set for the app
  final TextTheme textTheme;

  /// Return light [ColorScheme]
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3c6090),
      surfaceTint: Color(0xff3c6090),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd4e3ff),
      onPrimaryContainer: Color(0xff224876),
      secondary: Color(0xff904a43),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdad6),
      onSecondaryContainer: Color(0xff73332d),
      tertiary: Color(0xff6d5676),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff7d8ff),
      onTertiaryContainer: Color(0xff553f5e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff9f9ff),
      onSurface: Color(0xff191c20),
      onSurfaceVariant: Color(0xff43474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc3c6cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2e3035),
      inversePrimary: Color(0xffa5c8ff),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff001c3a),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff224876),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff3b0907),
      secondaryFixedDim: Color(0xffffb4ab),
      onSecondaryFixedVariant: Color(0xff73332d),
      tertiaryFixed: Color(0xfff7d8ff),
      onTertiaryFixed: Color(0xff271430),
      tertiaryFixedDim: Color(0xffdabde2),
      onTertiaryFixedVariant: Color(0xff553f5e),
      surfaceDim: Color(0xffd9dae0),
      surfaceBright: Color(0xfff9f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff2f3fa),
      surfaceContainer: Color(0xffededf4),
      surfaceContainerHigh: Color(0xffe7e8ee),
      surfaceContainerHighest: Color(0xffe1e2e9),
    );
  }

  /// Returns light [ThemeData]
  ThemeData light() {
    return theme(lightScheme());
  }

  /// Returns dark [ColorScheme]
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa5c8ff),
      surfaceTint: Color(0xffa5c8ff),
      onPrimary: Color(0xff00315e),
      primaryContainer: Color(0xff224876),
      onPrimaryContainer: Color(0xffd4e3ff),
      secondary: Color(0xffffb4ab),
      onSecondary: Color(0xff561e19),
      secondaryContainer: Color(0xff73332d),
      onSecondaryContainer: Color(0xffffdad6),
      tertiary: Color(0xffdabde2),
      onTertiary: Color(0xff3d2946),
      tertiaryContainer: Color(0xff553f5e),
      onTertiaryContainer: Color(0xfff7d8ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff111318),
      onSurface: Color(0xffe1e2e9),
      onSurfaceVariant: Color(0xffc3c6cf),
      outline: Color(0xff8d9199),
      outlineVariant: Color(0xff43474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe1e2e9),
      inversePrimary: Color(0xff3c6090),
      primaryFixed: Color(0xffd4e3ff),
      onPrimaryFixed: Color(0xff001c3a),
      primaryFixedDim: Color(0xffa5c8ff),
      onPrimaryFixedVariant: Color(0xff224876),
      secondaryFixed: Color(0xffffdad6),
      onSecondaryFixed: Color(0xff3b0907),
      secondaryFixedDim: Color(0xffffb4ab),
      onSecondaryFixedVariant: Color(0xff73332d),
      tertiaryFixed: Color(0xfff7d8ff),
      onTertiaryFixed: Color(0xff271430),
      tertiaryFixedDim: Color(0xffdabde2),
      onTertiaryFixedVariant: Color(0xff553f5e),
      surfaceDim: Color(0xff111318),
      surfaceBright: Color(0xff37393e),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff191c20),
      surfaceContainer: Color(0xff1d2024),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff32353a),
    );
  }

  /// Returns dart [ThemeData]
  ThemeData dark() {
    return theme(darkScheme());
  }

  /// Returns [ThemeData] with [colorScheme]
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}

/// Extension to helps get theme from [BuildContext]
extension ThemeX on BuildContext {
  /// Returns active [ColorScheme]
  ColorScheme get color => ColorScheme.of(this);

  /// Returns active [TextTheme]
  TextTheme get text => TextTheme.of(this);
}

/// Global spacing configuration for this app
abstract class AppSpacing {
  /// Returns padding for a page
  static const EdgeInsets pagePadding = EdgeInsets.all(16);
}
