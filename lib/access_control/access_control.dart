/// Possible resource that can be accessed
enum ResourceType {
  /// Faculty data resource
  faculty,
}

/// Possible action do to [ResourceType]
enum ActionType {
  /// Creating new resource action
  create,
}

/// Manage access control within this app
class AccessControl {
  /// Creates new [AccessControl]
  new();

  /// {@template AccessControl.permissionCheck}
  /// Check whether current user can do [action] on [resource]
  ///
  /// Return true when current user allowed. Otherwise, false.
  /// {@endtemplate}
  Future<bool> permissionCheck({
    required ActionType action,
    required ResourceType resource,
  }) async {
    // TODO(RDA-12): implement access control check
    return false;
  }
}
