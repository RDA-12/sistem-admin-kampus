import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/faculty/domain/entities.dart';
import 'package:sistem_admin/faculty/domain/use_cases/use_cases.dart';

/// Manage data on [Faculty]
abstract interface class IFacultyRepository
    extends
        BaseRepository<
          Faculty,
          CreateFacultyParams,
          UpdateFacultyParams,
          NoFilter
        >;
