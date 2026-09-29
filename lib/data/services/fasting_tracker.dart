import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'hijri_service.dart';

class FastingTracker extends Notifier<Set<String>> {
  Box<dynamic> get _box => Hive.box(AppConstants.prefsBox);

  @override
  Set<String> build() {
    final raw = _box.get(AppConstants.fastingDaysKey);
    if (raw is List) {
      return raw.map((e) => '$e').toSet();
    }
    return <String>{};
  }

  String keyFor(HijriDate date) => '${date.year}-${date.month}-${date.day}';

  bool isFasted(HijriDate date) => state.contains(keyFor(date));

  Future<void> toggle(HijriDate date) async {
    final next = {...state};
    final key = keyFor(date);
    if (!next.add(key)) next.remove(key);
    state = next;
    await _box.put(AppConstants.fastingDaysKey, next.toList());
  }

  int streakInRamadan(HijriDate today) {
    if (today.month != 9) return 0;
    var streak = 0;
    for (var d = today.day; d >= 1; d--) {
      final key = '${today.year}-9-$d';
      if (state.contains(key)) {
        streak++;
      } else if (d != today.day) {
        break;
      }
    }
    return streak;
  }
}

final fastingTrackerProvider =
    NotifierProvider<FastingTracker, Set<String>>(FastingTracker.new);

class CalendarFlags extends Notifier<({bool preview, bool reminders})> {
  Box<dynamic> get _box => Hive.box(AppConstants.prefsBox);

  @override
  ({bool preview, bool reminders}) build() {
    return (
      preview: _box.get(AppConstants.ramadanPreviewKey) as bool? ?? false,
      reminders: _box.get(AppConstants.fastingRemindersKey) as bool? ?? true,
    );
  }

  Future<void> setPreview(bool value) async {
    state = (preview: value, reminders: state.reminders);
    await _box.put(AppConstants.ramadanPreviewKey, value);
  }

  Future<void> setReminders(bool value) async {
    state = (preview: state.preview, reminders: value);
    await _box.put(AppConstants.fastingRemindersKey, value);
  }
}

final calendarFlagsProvider =
    NotifierProvider<CalendarFlags, ({bool preview, bool reminders})>(
  CalendarFlags.new,
);
