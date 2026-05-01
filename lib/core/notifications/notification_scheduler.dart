/// Reads the user's notification preferences and calls
/// [NotificationService] to schedule / cancel each type.

import '../storage/notification_prefs.dart';
import 'notification_channels.dart';
import 'notification_service.dart';

class NotificationScheduler {
  NotificationScheduler._();
  static final instance = NotificationScheduler._();

  final _svc = NotificationService.instance;

  /// Re-schedule everything based on current prefs.
  /// Call after any toggle or time change.
  Future<void> rescheduleAll() async {
    await _scheduleMealReminders();
    await _scheduleNutrientTip();
    await _scheduleStreakAlert();
    await _scheduleHydration();
    await _scheduleWeeklyReport();
    await _scheduleAiInsight();
  }

  // ── Meal Reminders ────────────────────────────────────────────

  Future<void> _scheduleMealReminders() async {
    final enabled = await NotificationPrefs.getMealReminders();

    if (!enabled) {
      await _svc.cancel(NotificationService.breakfastId);
      await _svc.cancel(NotificationService.lunchId);
      await _svc.cancel(NotificationService.dinnerId);
      return;
    }

    final breakfast = await NotificationPrefs.getBreakfastTime();
    final lunch = await NotificationPrefs.getLunchTime();
    final dinner = await NotificationPrefs.getDinnerTime();

    await _svc.scheduleDaily(
      id: NotificationService.breakfastId,
      channelId: NVChannels.mealReminders,
      title: 'Time for breakfast! 🌅',
      body: 'Start your day right — log your morning meal to track your nutrients.',
      hour: breakfast.hour,
      minute: breakfast.minute,
      payload: '/app/search',
    );

    await _svc.scheduleDaily(
      id: NotificationService.lunchId,
      channelId: NVChannels.mealReminders,
      title: 'Lunch time! 🥗',
      body: "Don't forget to log your midday meal. Every meal counts toward your daily goals.",
      hour: lunch.hour,
      minute: lunch.minute,
      payload: '/app/search',
    );

    await _svc.scheduleDaily(
      id: NotificationService.dinnerId,
      channelId: NVChannels.mealReminders,
      title: 'Dinner reminder 🍽️',
      body: "Log your evening meal to complete today's nutrient picture.",
      hour: dinner.hour,
      minute: dinner.minute,
      payload: '/app/search',
    );
  }

  // ── Nutrient Tip ──────────────────────────────────────────────

  Future<void> _scheduleNutrientTip() async {
    final enabled = await NotificationPrefs.getNutrientTips();

    if (!enabled) {
      await _svc.cancel(NotificationService.nutrientTipId);
      return;
    }

    // Daily at 10:30 AM
    await _svc.scheduleDaily(
      id: NotificationService.nutrientTipId,
      channelId: NVChannels.nutrientTips,
      title: 'Nutrient tip for you 🥦',
      body: "Check today's personalised food recommendations based on your nutrient gaps.",
      hour: 10,
      minute: 30,
      payload: '/app',
    );
  }

  // ── Streak Alert ──────────────────────────────────────────────

  Future<void> _scheduleStreakAlert() async {
    final enabled = await NotificationPrefs.getStreakAlerts();

    if (!enabled) {
      await _svc.cancel(NotificationService.streakId);
      return;
    }

    // Daily at 7 PM
    await _svc.scheduleDaily(
      id: NotificationService.streakId,
      channelId: NVChannels.streakUpdates,
      title: "Don't break your streak! 🔥",
      body: "Have you logged all your meals today? Keep your streak alive — you're doing great!",
      hour: 19,
      minute: 0,
      payload: '/app',
    );
  }

  // ── Hydration ─────────────────────────────────────────────────

  Future<void> _scheduleHydration() async {
    final enabled = await NotificationPrefs.getHydration();

    // Cancel all hydration slots first
    await _svc.cancelRange(
      NotificationService.hydrationBaseId,
      NotificationService.hydrationBaseId + 20,
    );

    if (!enabled) return;

    // Every 2 hours from 8 AM to 8 PM
    const messages = [
      'Start your morning with a glass of water 💧',
      'Time for a hydration break! Your body will thank you 💧',
      'Stay hydrated — grab some water! 💧',
      'Midday water check! Keep those fluids coming 💧',
      'Afternoon hydration reminder 💧',
      'Evening water break — stay refreshed! 💧',
      'Last hydration reminder — finish strong today 💧',
    ];

    for (var i = 0; i < 7; i++) {
      final hour = 8 + (i * 2); // 8, 10, 12, 14, 16, 18, 20
      await _svc.scheduleDaily(
        id: NotificationService.hydrationBaseId + i,
        channelId: NVChannels.hydration,
        title: 'Hydration reminder',
        body: messages[i],
        hour: hour,
        minute: 0,
        payload: '/app',
      );
    }
  }

  // ── Weekly Report ─────────────────────────────────────────────

  Future<void> _scheduleWeeklyReport() async {
    final enabled = await NotificationPrefs.getWeeklySummary();

    if (!enabled) {
      await _svc.cancel(NotificationService.weeklyReportId);
      return;
    }

    // Sunday evening at 7 PM
    await _svc.scheduleWeekly(
      id: NotificationService.weeklyReportId,
      channelId: NVChannels.weeklyReport,
      title: 'Your weekly nutrient report 📊',
      body: "See how well you covered your nutrient goals this week. Tap to view your progress!",
      dayOfWeek: DateTime.sunday,
      hour: 19,
      minute: 0,
      payload: '/app?tab=track',
    );
  }

  // ── AI Insight ────────────────────────────────────────────────

  Future<void> _scheduleAiInsight() async {
    final enabled = await NotificationPrefs.getAiInsights();

    if (!enabled) {
      await _svc.cancel(NotificationService.aiInsightId);
      return;
    }

    // Schedule at 11 AM — the matchDateTimeComponents: time
    // makes it repeat daily, which is fine as a gentle nudge.
    await _svc.scheduleDaily(
      id: NotificationService.aiInsightId,
      channelId: NVChannels.aiInsights,
      title: 'Try AI meal analysis 📸',
      body: "Snap a photo of your meal and let AI estimate the nutrients instantly. Give it a try!",
      hour: 11,
      minute: 0,
      payload: '/app/search',
    );
  }
}
