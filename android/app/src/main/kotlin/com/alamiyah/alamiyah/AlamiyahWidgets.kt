package com.alamiyah.alamiyah

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) = bind(context, appWidgetManager, appWidgetIds, widgetData, "prayer")
}

class AdhkarWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) = bind(context, appWidgetManager, appWidgetIds, widgetData, "adhkar")
}

class LessonsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) = bind(context, appWidgetManager, appWidgetIds, widgetData, "lessons")
}

private fun bind(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
    prefix: String,
) {
    appWidgetIds.forEach { widgetId ->
        val views = RemoteViews(context.packageName, R.layout.alamiyah_widget).apply {
            val pending = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_container, pending)
            setTextViewText(R.id.widget_kicker, widgetData.getString("${prefix}_kicker", ""))
            setTextViewText(R.id.widget_title, widgetData.getString("${prefix}_title", "Alamiyah"))
            setTextViewText(R.id.widget_body, widgetData.getString("${prefix}_body", ""))
        }
        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
