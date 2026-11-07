import 'dart:math';

import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/course_schedule/presentation/models.dart';
import 'package:sistem_admin/course_schedule/presentation/widgets/course_schedule_card.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const _headerCellHeight = 45.0;
const double _pinnedHeaderHeight = 2 * _headerCellHeight;
const _cellHeight = 60.0;
const _cellWidth = 128.0;
const _minutesPerCredit = 50;

final class _CourseSchedulePositioned {
  new({
    required this.schedule,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  final CourseScheduleUI schedule;
  final double top;
  final double left;
  final double width;
  final double height;
}

final class _CourseScheduleController extends ChangeNotifier {
  new({required this._calendar}) {
    _showedSchedules = [];
    _horizontalScrollController = ScrollController()..addListener(_onScroll);
    _verticalScrollController = ScrollController()..addListener(_onScroll);
    _semesterCellWidth = _cellWidth;
    _initCalendarMetrics();
  }

  void _initCalendarMetrics() {
    totalSemester = max(_calendar.listOfSemester.length, 1);
    // 7 days of total semester
    final totalSemesterColumns = totalSemester * 7;
    semesterCellWidthFraction = totalSemester / totalSemesterColumns;
    // time column + 7 days of total semesters
    totalColumns = 1 + totalSemesterColumns;
    listOfStartDayIndex = List.generate(
      7,
      (index) => (index + 1) * totalSemester - (totalSemester - 1),
    );
    mapColumnIndexToSemester = Map.fromIterables(
      listOfStartDayIndex
          .map(
            (dayIndex) =>
                List.generate(totalSemester, (index) => dayIndex + index),
          )
          .flattened,
      listOfStartDayIndex
          .map(
            (dayIndex) => List.generate(
              totalSemester,
              (index) => _calendar.listOfSemester.elementAtOrNull(index) ?? -1,
            ),
          )
          .flattened,
    );
    if (_viewPort != Size.zero) {
      _semesterCellWidth = semesterCellWidthFraction * _viewPort.width;
    }
  }

  Size _viewPort = Size.zero;
  void setViewPort(Size size) {
    if (_viewPort == size) return;
    _viewPort = size;
    _semesterCellWidth = semesterCellWidthFraction * size.width;
    _recalculateSchedules();
  }

  CourseScheduleCalendarUI _calendar;
  void setCalendar(CourseScheduleCalendarUI calendar) {
    _calendar = calendar;
    _initCalendarMetrics();
    _recalculateSchedules();
  }

  late List<_CourseSchedulePositioned> _showedSchedules;
  List<_CourseSchedulePositioned> get schedules => _showedSchedules;

  late final ScrollController _horizontalScrollController;
  ScrollController get horizontalScrollController =>
      _horizontalScrollController;
  double _horizontalOffset = 0;
  double get horizontalOffset => _horizontalOffset;

  late final ScrollController _verticalScrollController;
  ScrollController get verticalScrollController => _verticalScrollController;
  double _verticalOffset = 0;
  double get verticalOffset => _verticalOffset;

  late double semesterCellWidthFraction;
  late double _semesterCellWidth;

  final totalRows = 24; // 2 headers + 22 times (11 hours * 2, per 30 minutes)
  late int totalSemester;
  late int totalColumns;

  late List<int> listOfStartDayIndex;
  late Map<int, int> mapColumnIndexToSemester;

  void _onScroll() {
    _horizontalOffset = _horizontalScrollController.offset;
    _verticalOffset = _verticalScrollController.offset;
    _recalculateSchedules();
    notifyListeners();
  }

  void _recalculateSchedules() {
    _showedSchedules = _calendar.schedules
        .map((schedule) {
          final top = _getTopOffset(schedule);
          final left = _getLeftOffset(schedule);
          final width = _getWidth(schedule, isOnEdge: left == 0);
          final height = _getHeight(schedule, isOnEdge: top == 0);
          return _CourseSchedulePositioned(
            schedule: schedule,
            top: top,
            left: left,
            width: width,
            height: height,
          );
        })
        // Filter out invisible schedules
        .where(
          (it) =>
              it.width > 0 &&
              it.height > 0 &&
              it.top < _viewPort.height - _pinnedHeaderHeight &&
              it.left < _viewPort.width - _cellWidth,
        )
        .toList(growable: false);
  }

  double _getNormalTopOffset(CourseScheduleUI schedule) {
    final hour = schedule.start.hour;
    final minute = schedule.start.minute;
    // get normal offset, assumed 07:00 as 0 point
    return (((hour - 7) * 2) + (minute == 30 ? 1 : 0)) * _cellHeight;
  }

  double _getTopOffset(CourseScheduleUI schedule) {
    final topOffset = _getNormalTopOffset(schedule);
    // as it scroll, the 0 point no longer at 07:00
    final effectiveTopOffset = topOffset - _verticalOffset;
    return max(effectiveTopOffset, 0);
  }

  double _getNormalLeftOffset(CourseScheduleUI schedule) {
    // get normal offset, assumed first semester of monday as 0 point
    final semesterIdx = _calendar.listOfSemester.indexOf(
      schedule.course.semester,
    );
    final day = schedule.start.weekday;
    final columnNumber = (day - 1) * totalSemester + semesterIdx;
    return columnNumber * _semesterCellWidth;
  }

  double _getLeftOffset(CourseScheduleUI schedule) {
    final leftOffset = _getNormalLeftOffset(schedule);
    // adjust the offset as it scroll
    final effectiveLeftOffset = leftOffset - _horizontalOffset;
    return max(effectiveLeftOffset, 0);
  }

  double _getHeight(CourseScheduleUI schedule, {required bool isOnEdge}) {
    final totalMinutes = schedule.course.credit * _minutesPerCredit;
    // divided by 30 since the cell height is per 30 minutes
    final fullHeight = _cellHeight * (totalMinutes / 30);
    if (!isOnEdge) return fullHeight;
    final scrolledPast = _verticalOffset - _getNormalTopOffset(schedule);
    return max(0, fullHeight - scrolledPast);
  }

  double _getWidth(CourseScheduleUI schedule, {required bool isOnEdge}) {
    if (!isOnEdge) return _semesterCellWidth;
    final scrolledPast = _horizontalOffset - _getNormalLeftOffset(schedule);
    return max(0, _semesterCellWidth - scrolledPast);
  }

  @override
  void dispose() {
    verticalScrollController
      ..removeListener(_onScroll)
      ..dispose();
    horizontalScrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}

/// Creates timetable/calendar UI-like to shows [calendar] data
class CourseScheduleCalendar extends StatefulWidget {
  /// Creates new [CourseScheduleCalendar]
  const new({
    required this.calendar,
    super.key,
  });

  /// Course schedules that will be showed
  final CourseScheduleCalendarUI calendar;

  @override
  State<CourseScheduleCalendar> createState() => _CourseScheduleCalendarState();
}

class _CourseScheduleCalendarState extends State<CourseScheduleCalendar> {
  final DateTime startTime = DateTime.now().copyWith(hour: 7, minute: 0);

  late final _CourseScheduleController controller;

  @override
  void initState() {
    super.initState();
    controller = _CourseScheduleController(
      calendar: widget.calendar,
    );
  }

  @override
  void didUpdateWidget(covariant CourseScheduleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calendar == widget.calendar) return;
    controller.setCalendar(widget.calendar);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.setViewPort(constraints.biggest);
        return Stack(
          children: [
            TableView.builder(
              verticalDetails: ScrollableDetails.vertical(
                controller: controller.verticalScrollController,
              ),
              horizontalDetails: ScrollableDetails.horizontal(
                controller: controller.horizontalScrollController,
              ),
              rowCount: controller.totalRows,
              columnCount: controller.totalColumns,
              // Pin time column
              pinnedColumnCount: 1,
              // Pin header
              pinnedRowCount: 2,
              rowBuilder: (index) {
                if (index < 2) {
                  return Span(
                    extent: const FixedSpanExtent(_headerCellHeight),
                    backgroundDecoration: SpanDecoration(
                      border: SpanBorder(
                        leading: BorderSide(
                          color: context.color.outlineVariant,
                        ),
                        trailing: index == 1
                            ? BorderSide(color: context.color.outlineVariant)
                            : BorderSide.none,
                      ),
                    ),
                  );
                }
                return Span(
                  extent: const FixedSpanExtent(_cellHeight),
                  backgroundDecoration: SpanDecoration(
                    border: SpanBorder(
                      trailing: BorderSide(
                        color: context.color.outlineVariant,
                      ),
                    ),
                  ),
                );
              },
              columnBuilder: (index) {
                late final SpanExtent spanExtent;
                if (index == 0) {
                  spanExtent = const FixedSpanExtent(_cellWidth);
                } else {
                  spanExtent = FractionalSpanExtent(
                    controller.semesterCellWidthFraction,
                  );
                }
                return Span(
                  extent: spanExtent,
                  backgroundDecoration: SpanDecoration(
                    border: SpanBorder(
                      leading: index == 0
                          ? BorderSide(
                              color: context.color.outlineVariant,
                            )
                          : BorderSide.none,
                      trailing: BorderSide(
                        color: context.color.outlineVariant,
                      ),
                    ),
                  ),
                );
              },
              cellBuilder: (context, vicinity) {
                // Top-left header
                if (vicinity.row == 0 && vicinity.column == 0) {
                  return const TableViewCell(
                    child: SizedBox.shrink(),
                  );
                }
                // Header
                if (vicinity.row < 2 && vicinity.column > 0) {
                  // Semester header
                  if (vicinity.row == 1) {
                    final semester =
                        controller.mapColumnIndexToSemester[vicinity.column];
                    return TableViewCell(
                      child: _HeaderCell(title: 'Semester $semester'),
                    );
                  }
                  // Day header
                  if (controller.listOfStartDayIndex.contains(
                    vicinity.column,
                  )) {
                    final dayIndex = controller.listOfStartDayIndex.indexOf(
                      vicinity.column,
                    );
                    return TableViewCell(
                      columnMergeStart: vicinity.column,
                      columnMergeSpan: controller.totalSemester,
                      child: _HeaderCell(title: DayOfWeek.fullName[dayIndex]),
                    );
                  }
                }
                // Time rows
                if (vicinity.column == 0) {
                  if (vicinity.row > 1) {
                    final timeIndex = vicinity.row - 2;
                    final timeToShow = startTime.add(
                      Duration(minutes: 30 * timeIndex),
                    );
                    return TableViewCell(
                      child: _TimeCell(time: timeToShow.timeFormat()),
                    );
                  }
                }

                return const TableViewCell(
                  child: SizedBox.expand(),
                );
              },
            ),
            Positioned(
              top: _pinnedHeaderHeight,
              left: _cellWidth,
              right: 0,
              bottom: 0,
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return Stack(
                    children: [
                      for (final value in controller.schedules)
                        Positioned(
                          top: value.top,
                          left: value.left,
                          width: value.width,
                          height: value.height,
                          child: CourseScheduleCard(
                            schedule: value.schedule,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimeCell extends StatelessWidget {
  const new({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        time,
        textAlign: .center,
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const new({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: context.text.bodyMedium?.copyWith(fontWeight: .bold),
        textAlign: .center,
      ),
    );
  }
}
