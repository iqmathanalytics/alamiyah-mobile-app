import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_times_service.dart';

class FastingReminderService {
  FastingReminderService._();
  static final instance = FastingReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone init skipped: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _ready = true;
  }

  /// Ask for notification permission (Android 13+ / iOS). Safe to call often.
  Future<bool> requestPermission() async {
    if (kIsWeb || !_ready) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> sync({
    required bool enabled,
    required bool ramadanActive,
    required PrayerLocation location,
  }) async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancelAll();
    if (!enabled || !ramadanActive) return;

    final allowed = await requestPermission();
    if (!allowed) {
      debugPrint('Notification permission denied — reminders not scheduled');
      return;
    }

    // Channel id bumped when custom sound was added so Android recreates it.
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'fasting_v2',
        'Fasting reminders',
        channelDescription: 'Suhoor and iftar reminders during Ramadan',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alamiyah_confirm'),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alamiyah_confirm.wav',
      ),
    );

    final now = DateTime.now();
    var id = 40;
    for (var i = 0; i < 3; i++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final prayers = calculatePrayers(location, day);
      final suhoor = prayers.fajr.subtract(const Duration(minutes: 40));
      if (suhoor.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: id++,
          title: 'Suhoor window',
          body: 'Fajr is in about 40 minutes. May Allah accept your fast.',
          scheduledDate: tz.TZDateTime.from(suhoor, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
      if (prayers.maghrib.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: id++,
          title: 'Time for iftar',
          body: 'Maghrib is here. Break your fast with a calm heart.',
          scheduledDate: tz.TZDateTime.from(prayers.maghrib, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}
