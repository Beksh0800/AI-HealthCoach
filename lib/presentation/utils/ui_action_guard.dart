import 'dart:async';

import 'package:flutter/foundation.dart';

class UiActionGuard<TModalType> {
  UiActionGuard({required this.debugLabel});

  final String debugLabel;
  final Set<String> _inFlight = <String>{};
  final Map<String, DateTime> _lastCompletedAt = <String, DateTime>{};
  _ActiveModalSession<TModalType>? _activeModalSession;

  Future<void> run(
    String key,
    FutureOr<void> Function() action, {
    Duration minInterval = const Duration(milliseconds: 250),
  }) async {
    final now = DateTime.now();
    final lastCompletedAt = _lastCompletedAt[key];
    if (lastCompletedAt != null &&
        now.difference(lastCompletedAt) < minInterval) {
      debugPrint(
        '$debugLabel: Ignored "$key" due to debounce (${now.difference(lastCompletedAt).inMilliseconds}ms)',
      );
      return;
    }

    if (_inFlight.contains(key)) {
      debugPrint('$debugLabel: Ignored "$key" while action is in-flight');
      return;
    }

    _inFlight.add(key);
    try {
      await action();
    } finally {
      _inFlight.remove(key);
      _lastCompletedAt[key] = DateTime.now();
    }
  }

  Future<void> runModal(
    String key, {
    required TModalType modalType,
    required FutureOr<void> Function() action,
    Duration minInterval = const Duration(milliseconds: 250),
    bool idempotentWhenSameModalOpen = false,
  }) {
    return run(key, () async {
      final activeModalType = _activeModalSession?.type;
      if (activeModalType != null) {
        if (activeModalType == modalType && idempotentWhenSameModalOpen) {
          debugPrint(
            '$debugLabel: Ignored "$key" because "$modalType" modal is already open (idempotent open)',
          );
          return;
        }

        debugPrint(
          '$debugLabel: Ignored "$key" because "$activeModalType" modal is already open',
        );
        return;
      }

      final session = _ActiveModalSession<TModalType>(
        key: key,
        type: modalType,
      );
      _activeModalSession = session;
      debugPrint('$debugLabel: Opened "$modalType" modal via "$key"');

      try {
        await action();
      } finally {
        if (identical(_activeModalSession, session)) {
          _activeModalSession = null;
          debugPrint('$debugLabel: Closed "$modalType" modal via "$key"');
        }
      }
    }, minInterval: minInterval);
  }
}

final class _ActiveModalSession<TModalType> {
  const _ActiveModalSession({required this.key, required this.type});

  final String key;
  final TModalType type;
}
