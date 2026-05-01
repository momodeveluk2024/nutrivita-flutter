/// Manages notification preferences and exposes reactive state
/// for the notification settings UI.

import 'package:flutter/material.dart';

import '../notifications/notification_scheduler.dart';
import '../notifications/notification_service.dart';
import '../storage/notification_prefs.dart';

class NotificationProvider extends ChangeNotifier {
  // ── Observable state ──────────────────────────────────────────
  bool mealReminders = true;
  bool nutrientTips = true;
  bool streakAlerts = true;
  bool hydration = false;
  bool weeklySummary = true;
  bool aiInsights = false;

  TimeOfDay breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay lunchTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  bool isLoading = true;

  /// Load all saved prefs and request permission if first time.
  Future<void> initialize() async {
    mealReminders = await NotificationPrefs.getMealReminders();
    nutrientTips = await NotificationPrefs.getNutrientTips();
    streakAlerts = await NotificationPrefs.getStreakAlerts();
    hydration = await NotificationPrefs.getHydration();
    weeklySummary = await NotificationPrefs.getWeeklySummary();
    aiInsights = await NotificationPrefs.getAiInsights();

    breakfastTime = await NotificationPrefs.getBreakfastTime();
    lunchTime = await NotificationPrefs.getLunchTime();
    dinnerTime = await NotificationPrefs.getDinnerTime();

    isLoading = false;
    notifyListeners();

    // Request permission on first launch
    final alreadyRequested = await NotificationPrefs.wasPermissionRequested();
    if (!alreadyRequested) {
      await NotificationService.instance.requestPermission();
      await NotificationPrefs.markPermissionRequested();
    }

    // Schedule based on current prefs
    await NotificationScheduler.instance.rescheduleAll();
  }

  // ── Toggles ───────────────────────────────────────────────────

  Future<void> setMealReminders(bool v) async {
    mealReminders = v;
    notifyListeners();
    await NotificationPrefs.setMealReminders(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setNutrientTips(bool v) async {
    nutrientTips = v;
    notifyListeners();
    await NotificationPrefs.setNutrientTips(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setStreakAlerts(bool v) async {
    streakAlerts = v;
    notifyListeners();
    await NotificationPrefs.setStreakAlerts(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setHydration(bool v) async {
    hydration = v;
    notifyListeners();
    await NotificationPrefs.setHydration(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setWeeklySummary(bool v) async {
    weeklySummary = v;
    notifyListeners();
    await NotificationPrefs.setWeeklySummary(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setAiInsights(bool v) async {
    aiInsights = v;
    notifyListeners();
    await NotificationPrefs.setAiInsights(v);
    await NotificationScheduler.instance.rescheduleAll();
  }

  // ── Meal time changes ─────────────────────────────────────────

  Future<void> setBreakfastTime(TimeOfDay t) async {
    breakfastTime = t;
    notifyListeners();
    await NotificationPrefs.setBreakfastTime(t);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setLunchTime(TimeOfDay t) async {
    lunchTime = t;
    notifyListeners();
    await NotificationPrefs.setLunchTime(t);
    await NotificationScheduler.instance.rescheduleAll();
  }

  Future<void> setDinnerTime(TimeOfDay t) async {
    dinnerTime = t;
    notifyListeners();
    await NotificationPrefs.setDinnerTime(t);
    await NotificationScheduler.instance.rescheduleAll();
  }
}
