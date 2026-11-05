import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_calendar_event_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/filters/academic_term_filter.dart';
import 'package:sistem_admin/academic_calendar/domain/use_cases/use_cases.dart';
import 'package:sistem_admin/common/common.dart';

/// Manage data on [AcademicYear]
abstract interface class IAcademicYearRepository
    extends
        BaseRepository<
          AcademicYear,
          CreateAcademicYearParams,
          UpdateAcademicYearParams,
          NoFilter
        >;

/// Manage data on [AcademicTerm]
abstract interface class IAcademicTermRepository
    extends
        BaseRepository<
          AcademicTerm,
          CreateAcademicTermParams,
          UpdateAcademicTermParams,
          AcademicTermFilter
        >;

/// Manage data on [AcademicCalendarEvent]
abstract interface class IAcademicCalendarEventRepository
    extends
        BaseRepository<
          AcademicCalendarEvent,
          CreateAcademicCalendarEventParams,
          UpdateAcademicCalendarEventParams,
          AcademicCalendarEventFilter
        >;
