import 'package:equatable/equatable.dart';
import 'package:sistem_admin/core/app_exception.dart';

/// Wrapper for all operations result wihin this app.
///
/// It could be [AppFailure] or [AppSuccess]
sealed class AppResult<T> {
  const new();

  /// Creates new success result
  factory success(T data) {
    return AppSuccess(data: data);
  }

  /// Creates new failure result
  factory failure(AppException exception) {
    return AppFailure(exception: exception);
  }
}

/// Failure result of [AppResult]
class AppFailure<T> extends AppResult<T> with Equatable {
  /// Creates new [AppFailure] with [exception]
  const new({required this.exception});

  /// Exception that thrown when the operation fails
  final AppException exception;

  @override
  List<Object?> get props => [exception];
}

/// Success result of [AppResult]
class AppSuccess<T> extends AppResult<T> with Equatable {
  /// Creates new [AppSuccess] with [data]
  const new({required this.data});

  /// Data returned when the operation success
  final T data;

  @override
  List<Object?> get props => [data];
}
