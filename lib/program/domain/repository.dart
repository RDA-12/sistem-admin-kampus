import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/program/domain/entities.dart';
import 'package:sistem_admin/program/domain/filters/program_filter.dart';
import 'package:sistem_admin/program/domain/use_cases/use_cases.dart';

/// Manage data on [Program]
abstract interface class IProgramRepository
    extends
        BaseRepository<
          Program,
          CreateProgramParams,
          UpdateProgramParams,
          ProgramFilter
        >;
