import 'package:sistem_admin/common/common.dart';
import 'package:sistem_admin/lecturer/domain/entities.dart';
import 'package:sistem_admin/lecturer/domain/filters/lecturer_filter.dart';
import 'package:sistem_admin/lecturer/domain/use_cases/use_cases.dart';

/// Manage data on [Lecturer]
abstract interface class ILecturerRepository
    extends
        BaseRepository<
          Lecturer,
          CreateLecturerParams,
          UpdateLecturerParams,
          LecturerFilter
        >;
