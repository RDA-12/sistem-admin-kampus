import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';

/// Builder function definition for [TwoPaneLayoutBuilder]
typedef TwoPaneLayoutBuilderFunc<T> = Widget Function(
  BuildContext context,
  TwoPaneLayoutController<T> controller,
  BreakPoint breakPoint,
  BoxConstraints constraints,
);

/// Controller for [TwoPaneLayoutBuilder]
final class TwoPaneLayoutController<T> extends ChangeNotifier {
  /// Creates new [TwoPaneLayoutController]
  new({required this._data});

  T _data;

  /// Additional data from user
  ///
  /// Useful to make left/right pane conditinally showed
  T get data => _data;

  set data(T data) {
    _data = data;
    notifyListeners();
  }
}

/// {@template TwoPaneLayoutBuilder}
/// Creates two pane layout for screen > [BreakPoint.medium]
/// and one pane for screen < [BreakPoint.expanded]
/// {@endtemplate}
class TwoPaneLayoutBuilder<T> extends StatefulWidget {
  /// Creates new [TwoPaneLayoutBuilder]
  ///
  /// {@macro TwoPaneLayoutBuilder}
  const new({
    required this.leftBuilder,
    required this.initialAdditionalData,
    this.rightBuilder,
    super.key,
  });

  /// Initial additional data that will be embedded to controller
  /// which can be changed through controller that will be provided
  /// within the [leftBuilder] and [rightBuilder]
  ///
  /// It useful to conditionally shows left and right pane.
  final T initialAdditionalData;

  /// Builder function for the left pane
  final TwoPaneLayoutBuilderFunc<T> leftBuilder;

  /// Builder function for the right pane
  ///
  /// It will be completely ignored on [BreakPoint.compact]
  /// & [BreakPoint.medium].
  ///
  /// It default to shows [SizedBox.shrink].
  final TwoPaneLayoutBuilderFunc<T>? rightBuilder;

  @override
  State<TwoPaneLayoutBuilder<T>> createState() =>
      _TwoPaneLayoutBuilderState<T>();
}

class _TwoPaneLayoutBuilderState<T> extends State<TwoPaneLayoutBuilder<T>> {
  late final TwoPaneLayoutController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = TwoPaneLayoutController(data: widget.initialAdditionalData);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return ResponsiveBuilder(
          builder: (context, breakPoint, constraints) {
            if (breakPoint < BreakPoint.expanded) {
              return widget.leftBuilder(
                context,
                _controller,
                breakPoint,
                constraints,
              );
            }
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: breakPoint > BreakPoint.compact
                        ? const BorderRadiusGeometry.only(
                            topRight: Radius.circular(16),
                          )
                        : BorderRadius.zero,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return widget.leftBuilder(
                          context,
                          _controller,
                          breakPoint,
                          constraints,
                        );
                      },
                    ),
                  ),
                ),
                VerticalDivider(
                  width: AppSpacing.paneSpacing,
                  color: context.mainShellSurface,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadiusGeometry.vertical(
                      top: Radius.circular(16),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (widget.rightBuilder == null) {
                          return const SizedBox.shrink();
                        }
                        return widget.rightBuilder!(
                          context,
                          _controller,
                          breakPoint,
                          constraints,
                        );
                      },
                    ),
                  ),
                ),
                VerticalDivider(
                  width: AppSpacing.paneSpacing,
                  color: context.mainShellSurface,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
