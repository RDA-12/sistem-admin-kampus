import 'package:sistem_admin/common/data/filter.dart';
import 'package:sistem_admin/core/core.dart';

/// Base class for all repositories within this app
abstract class BaseRepository<
  T,
  SaveArgs,
  UpdateArgs,
  FilterArgs extends Filter
> {
  /// Save new [T] with [args]
  Future<AppResult<T>> save(SaveArgs args);

  /// Delete [T] with [id]
  Future<AppResult<Null>> delete(String id);

  /// Watch for [T] data changes with optional [filter]
  Stream<AppResult<List<T>>> watch([FilterArgs? filter]);

  /// Watch single [T] with [id] data changes
  Stream<AppResult<T>> watchSingle(String id);

  /// Update [T] with [id] based on [args]
  Future<AppResult<T>> update(String id, {required UpdateArgs args});
}
