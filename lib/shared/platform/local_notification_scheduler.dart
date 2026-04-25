import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../errors/app_error.dart';

abstract interface class LocalNotificationScheduler {
  Future<void> initialize();
  Future<NotificationPermissionState> requestPermission();
  Future<List<int>> scheduleWeeklyReminder({
    required int idBase,
    required String title,
    required String body,
    required TimeOfDayValue time,
    required Set<int> weekdays,
    String? payload,
  });
  Future<void> cancel(int id);
  Future<void> cancelMany(Iterable<int> ids);
}

enum NotificationPermissionState { unknown, granted, denied, limited }

class TimeOfDayValue {
  TimeOfDayValue({required this.hour, required this.minute}) {
    if (hour < 0 || hour > 23) {
      throw const AppError(
        code: AppErrorCode.validation,
        message: 'ساعة التذكير يجب أن تكون بين 0 و 23.',
      );
    }
    if (minute < 0 || minute > 59) {
      throw const AppError(
        code: AppErrorCode.validation,
        message: 'دقيقة التذكير يجب أن تكون بين 0 و 59.',
      );
    }
  }

  final int hour;
  final int minute;

  String get storageValue {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class FlutterLocalNotificationScheduler implements LocalNotificationScheduler {
  FlutterLocalNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'raqeem_reminders';
  static const _androidChannelName = 'تذكيرات رقيم';
  static const _androidChannelDescription =
      'تذكيرات قراءة القرآن اليومية والأسبوعية';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    timezone_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    _isInitialized = true;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    await initialize();
    final androidResult = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    if (androidResult != null) {
      return androidResult
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }

    final iosResult = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (iosResult != null) {
      return iosResult
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }

    return NotificationPermissionState.unknown;
  }

  @override
  Future<List<int>> scheduleWeeklyReminder({
    required int idBase,
    required String title,
    required String body,
    required TimeOfDayValue time,
    required Set<int> weekdays,
    String? payload,
  }) async {
    await initialize();
    if (weekdays.isEmpty || weekdays.any((day) => day < 1 || day > 7)) {
      throw const AppError(
        code: AppErrorCode.validation,
        message: 'أيام التذكير يجب أن تكون من 1 إلى 7 حسب معيار ISO.',
      );
    }

    final ids = <int>[];
    for (final weekday in weekdays.toList()..sort()) {
      final id = idBase + weekday;
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfWeekday(time, weekday),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
      );
      ids.add(id);
    }

    return ids;
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(TimeOfDayValue time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

@visibleForTesting
class NoopLocalNotificationScheduler implements LocalNotificationScheduler {
  final scheduledIds = <int>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.granted;
  }

  @override
  Future<List<int>> scheduleWeeklyReminder({
    required int idBase,
    required String title,
    required String body,
    required TimeOfDayValue time,
    required Set<int> weekdays,
    String? payload,
  }) async {
    final ids = weekdays.map((weekday) => idBase + weekday).toList()..sort();
    scheduledIds.addAll(ids);
    return ids;
  }

  @override
  Future<void> cancel(int id) async {
    scheduledIds.remove(id);
  }

  @override
  Future<void> cancelMany(Iterable<int> ids) async {
    scheduledIds.removeWhere(ids.toSet().contains);
  }
}
