import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Bottom-tab branches managed by [StatefulShellRoute].
enum AppTabBranch { home, workout, history, profile }

extension AppTabBranchX on AppTabBranch {
  int get index {
    switch (this) {
      case AppTabBranch.home:
        return 0;
      case AppTabBranch.workout:
        return 1;
      case AppTabBranch.history:
        return 2;
      case AppTabBranch.profile:
        return 3;
    }
  }

  String get routePath {
    switch (this) {
      case AppTabBranch.home:
        return AppRoutes.home;
      case AppTabBranch.workout:
        return AppRoutes.workout;
      case AppTabBranch.history:
        return AppRoutes.history;
      case AppTabBranch.profile:
        return AppRoutes.profile;
    }
  }

  static AppTabBranch? fromRoutePath(String routePath) {
    switch (routePath) {
      case AppRoutes.home:
        return AppTabBranch.home;
      case AppRoutes.workout:
        return AppTabBranch.workout;
      case AppRoutes.history:
        return AppTabBranch.history;
      case AppRoutes.profile:
        return AppTabBranch.profile;
      default:
        return null;
    }
  }
}

extension TabBranchNavigationContext on BuildContext {
  /// Branch-aware transition to a tab route.
  ///
  /// If [StatefulNavigationShell] is available, tab switching is done via
  /// `goBranch` to keep selected tab index synchronized.
  ///
  /// Outside shell context it falls back to `go(routePath)`.
  void goToTabBranch(
    AppTabBranch branch, {
    bool initialLocation = false,
    Object? extra,
  }) {
    final navigationShell = _maybeNavigationShell();

    if (navigationShell != null && extra == null) {
      if (!initialLocation && navigationShell.currentIndex == branch.index) {
        return;
      }
      navigationShell.goBranch(branch.index, initialLocation: initialLocation);
      return;
    }

    go(branch.routePath, extra: extra);
  }

  void goToTabRoute(
    String routePath, {
    bool initialLocation = false,
    Object? extra,
  }) {
    final branch = AppTabBranchX.fromRoutePath(routePath);
    if (branch == null) {
      go(routePath, extra: extra);
      return;
    }

    goToTabBranch(branch, initialLocation: initialLocation, extra: extra);
  }

  StatefulNavigationShellState? _maybeNavigationShell() {
    return StatefulNavigationShell.maybeOf(this);
  }
}
