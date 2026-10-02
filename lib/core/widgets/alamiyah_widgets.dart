import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/services/prayer_times_service.dart';
import '../l10n/app_strings.dart';

class AlamiyahWidgets {
  static Future<void> push(DayPrayers prayers, AppStrings strings) async {
    final nextTime = _clock(prayers.nextAt);
    final now = DateTime.now();
    final morning = now.hour < 15;
    final lessons = _lessons[now.day % _lessons.length];

    try {
      await HomeWidget.saveWidgetData<String>('prayer_kicker', strings.next);
      await HomeWidget.saveWidgetData<String>(
        'prayer_title',
        strings.prayer(prayers.next),
      );
      await HomeWidget.saveWidgetData<String>('prayer_body', nextTime);
      await HomeWidget.saveWidgetData<String>('adhkar_kicker', 'Adhkar');
      await HomeWidget.saveWidgetData<String>(
        'adhkar_title',
        morning ? 'سبحان الله وبحمده' : 'أستغفر الله',
      );
      await HomeWidget.saveWidgetData<String>(
        'adhkar_body',
        morning ? strings.prayer('Fajr') : strings.prayer('Maghrib'),
      );
      await HomeWidget.saveWidgetData<String>('lessons_kicker', strings.forYou);
      await HomeWidget.saveWidgetData<String>('lessons_title', lessons.$1);
      await HomeWidget.saveWidgetData<String>('lessons_body', lessons.$2);

      for (final name in const [
        'com.alamiyah.alamiyah.PrayerWidgetProvider',
        'com.alamiyah.alamiyah.AdhkarWidgetProvider',
        'com.alamiyah.alamiyah.LessonsWidgetProvider',
      ]) {
        await HomeWidget.updateWidget(qualifiedAndroidName: name);
      }
    } catch (error, stack) {
      debugPrint('Home widget update skipped: $error\n$stack');
    }
  }

  static String _clock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

const _lessons = [
  ('Aqidah', 'Allah is one, without partner.'),
  ('Fiqh', 'The prayer begins with a clear intention.'),
  ('Tasawwuf', 'A quiet heart remembers more than a hurried tongue.'),
];
