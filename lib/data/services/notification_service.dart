import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Service for scheduling workout reminder notifications.
class NotificationService {
  static const String _prefEnabled = 'reminder_enabled';
  static const String _prefHour = 'reminder_hour';
  static const String _prefMinute = 'reminder_minute';
  static const String _prefDays = 'reminder_days'; // comma-separated 1-7

  static const int _notificationId = 1001;
  static const String _channelId = 'workout_reminders';
  static const String _channelName = 'Напоминания о тренировках';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification plugin. Call once from main.
  Future<void> init() async {
    if (_initialized) return;

    await _configureTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_notify',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;

    // Re-schedule if reminders were enabled
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefEnabled) ?? false) {
      try {
        // Do not show permission dialogs during app bootstrap.
        await _scheduleFromPrefs(prefs, requestPermissions: false);
      } catch (e) {
        debugPrint('NotificationService: bootstrap re-schedule skipped: $e');
      }
    }
  }

  // ── Public API ──────────────────────────────────

  /// Whether reminders are currently enabled.
  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefEnabled) ?? false;
  }

  /// Saved reminder hour (0-23).
  Future<int> get hour async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefHour) ?? 9;
  }

  /// Saved reminder minute (0-59).
  Future<int> get minute async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefMinute) ?? 0;
  }

  /// Saved days as list of weekday numbers (1 = Mon … 7 = Sun).
  Future<List<int>> get days async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefDays);
    if (raw == null || raw.isEmpty) return [1, 2, 3, 4, 5]; // Mon-Fri default
    return raw.split(',').map(int.parse).toList();
  }

  /// Enable/disable reminders.
  Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      final granted = await ensurePermissions();
      if (!granted) {
        await prefs.setBool(_prefEnabled, false);
        return false;
      }
      await prefs.setBool(_prefEnabled, true);
      await _scheduleFromPrefs(prefs);
    } else {
      await prefs.setBool(_prefEnabled, false);
      await cancelAll();
    }
    return true;
  }

  /// Set the reminder time.
  Future<void> setTime(int h, int m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, h);
    await prefs.setInt(_prefMinute, m);
    if (prefs.getBool(_prefEnabled) ?? false) {
      await _scheduleFromPrefs(prefs);
    }
  }

  /// Set which weekdays to send reminders (1=Mon…7=Sun).
  Future<void> setDays(List<int> weekdays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefDays, weekdays.join(','));
    if (prefs.getBool(_prefEnabled) ?? false) {
      await _scheduleFromPrefs(prefs);
    }
  }

  /// Cancel all scheduled reminders.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('NotificationService: all reminders cancelled');
  }

  // ── Private helpers ─────────────────────────────

  Future<void> _scheduleFromPrefs(
    SharedPreferences prefs, {
    bool requestPermissions = true,
  }) async {
    final granted = requestPermissions
        ? await ensurePermissions()
        : await _hasPermissionsForAutoReschedule();
    if (!granted) {
      debugPrint('NotificationService: permission denied, skipping schedule');
      return;
    }

    final h = prefs.getInt(_prefHour) ?? 9;
    final m = prefs.getInt(_prefMinute) ?? 0;
    final rawDays = prefs.getString(_prefDays);
    final weekdays = (rawDays == null || rawDays.isEmpty)
        ? [1, 2, 3, 4, 5]
        : rawDays.split(',').map(int.parse).toList();

    await _plugin.cancelAll();

    for (final day in weekdays) {
      await _scheduleWeekly(day, h, m);
    }
    debugPrint(
      'NotificationService: scheduled for $weekdays at $h:${m.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _scheduleWeekly(int weekday, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to the correct weekday
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    // If it's in the past, move to next week
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    try {
      await _plugin.zonedSchedule(
        id: _notificationId + weekday,
        title: '🏋️ Время тренировки!',
        body:
            'Не забудь провести тренировку сегодня. Твоё здоровье в твоих руках!',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Напоминания о тренировках',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_notify',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      debugPrint(
        'NotificationService: error scheduling for weekday $weekday: $e',
      );
    }
  }

  Future<bool> ensurePermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final notificationsGranted = await android
          .requestNotificationsPermission();
      if (notificationsGranted == false) {
        debugPrint('NotificationService: notifications permission denied');
        return false;
      }

      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact == false) {
        await android.requestExactAlarmsPermission();
      }
      return true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (mac != null) {
      return await mac.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  Future<bool> _hasPermissionsForAutoReschedule() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      // Passive check only: no runtime dialogs during startup.
      final notificationsEnabled = await android.areNotificationsEnabled();
      if (notificationsEnabled == false) {
        return false;
      }
      return true;
    }

    // For non-Android platforms, keep startup path non-blocking.
    return true;
  }

  Future<void> _configureTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      debugPrint('NotificationService: local timezone set to $timezoneName');
    } catch (e) {
      debugPrint(
        'NotificationService: failed to resolve local timezone, fallback to UTC: $e',
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }
}
