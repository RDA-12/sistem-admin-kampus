import 'package:sistem_admin/academic_calendar/domain/entities.dart';
import 'package:sistem_admin/academic_calendar/domain/use_cases/use_cases.dart';
import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/core/core.dart';

/// Manage data on [AcademicYear]
abstract interface class IAcademicYearRepository
    extends
        BaseRepository<
          AcademicYear,
          CreateAcademicYearParams,
          UpdateAcademicYearParams
        >;

/// Manage data on [AcademicTerm]
abstract interface class IAcademicTermRepository
    extends
        BaseRepository<
          AcademicTerm,
          CreateAcademicTermParams,
          UpdateAcademicTermParams
        > {
  /// Watch for [AcademicTerm] data changes for specific [academicYearId]
  Stream<AppResult<List<AcademicTerm>>> watchByAcademicYear(
    String academicYearId,
  );
}

/// Manage data on [AcademicCalendarEvent]
abstract interface class IAcademicCalendarEventRepository
    extends
        BaseRepository<
          AcademicCalendarEvent,
          CreateAcademicCalendarEventParams,
          UpdateAcademicCalendarEventParams
        > {
  /// Watch for [AcademicCalendarEvent] data changes for specific
  /// [academicYearId]
  Stream<AppResult<List<AcademicCalendarEvent>>> watchByAcademicYear(
    String academicYearId,
  );
}
