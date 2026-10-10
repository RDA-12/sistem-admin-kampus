import 'package:material_ui/material_ui.dart';

/// Possible breakpoints for responsive UI
enum BreakPoint implements Comparable<BreakPoint> {
  /// screen < 600 in width
  ///
  /// Typically:
  /// - Phone in portrait
  compact,

  /// 600 <= screen < 840 in width
  ///
  /// Typically:
  /// - Table in portrait
  /// - Unfolded foldable phone
  medium,

  /// 840 <= screen < 1200
  ///
  /// Typically:
  /// - Phone in landscape
  /// - Tablet in landscape
  /// - Unfolded foldable phone in landscape
  /// - Desktop
  expanded,

  /// screen >= 1200
  ///
  /// Typically:
  /// - Desktop
  large;

  /// Returns [BreakPoint] based on [size]
  factory fromSize(Size size) {
    final width = size.width;
    if (width < 600) {
      return BreakPoint.compact;
    } else if (width >= 600 && width < 840) {
      return BreakPoint.medium;
    } else if (width >= 840 && width < 1200) {
      return BreakPoint.expanded;
    }
    return BreakPoint.large;
  }

  /// Returns maxWidth of this breakpoint
  double get maxWidth => switch (this) {
    BreakPoint.compact => 599,
    BreakPoint.medium => 839,
    BreakPoint.expanded => 1199,
    BreakPoint.large => double.infinity,
  };

  @override
  int compareTo(BreakPoint other) {
    if (other.maxWidth.isInfinite) return -1;
    if (maxWidth.isInfinite) return 1;
    return (maxWidth - other.maxWidth).ceil();
  }

  /// Returns true when this breakpoint is larger than [other]
  bool operator >(BreakPoint other) {
    return compareTo(other) > 0;
  }

  /// Returns true when this breakpoint is smaller than [other]
  bool operator <(BreakPoint other) {
    return compareTo(other) < 0;
  }

  /// Returns true when this breakpoint is inside [breakpoints]
  bool inside(List<BreakPoint> breakpoints) {
    return breakpoints.contains(this);
  }
}

/// {@template ResponsiveBuilder}
/// Provides [BuildContext], [BreakPoint] and [BoxConstraints] from its parent
///
/// [BreakPoint] will be based on phone's width not parent width.
/// So, there might be case where [BreakPoint.expanded]
/// has [BoxConstraints.maxWidth] = 600
/// {@endtemplate}
class ResponsiveBuilder extends StatelessWidget {
  /// Creates new [ResponsiveBuilder]
  ///
  /// {@macro ResponsiveBuilder}
  const new({required this.builder, super.key});

  /// Builder to build Widget that will be showed
  final Widget Function(BuildContext, BreakPoint, BoxConstraints) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneSize = MediaQuery.sizeOf(context);
        final breakPoint = BreakPoint.fromSize(phoneSize);
        return builder(context, breakPoint, constraints);
      },
    );
  }
}
