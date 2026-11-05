import 'package:sistem_admin/cohort/domain/entities.dart';
import 'package:sistem_admin/cohort/domain/use_cases/use_cases.dart';
import 'package:sistem_admin/common/common.dart';

/// Manage data on [Cohort]
abstract interface class ICohortRepository
    extends
        BaseRepository<
          Cohort,
          CreateCohortParams,
          UpdateCohortParams,
          NoFilter
        >;
