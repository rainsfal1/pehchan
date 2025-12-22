import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../utils/reminder_calculator.dart';

/// Singleton service for managing local notifications and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  /// Callback for handling navigation when notification is tapped
  Function(String route, Map<String, String> params)? onNotificationTap;

  factory NotificationService() => _instance;

  NotificationService._internal()
      : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification service with platform-specific settings
  Future<void> initialize() async {
    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with notification tap handler
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel
      if (Platform.isAndroid) {
        await _createAndroidNotificationChannel();
      }

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      // Don't rethrow - allow app to continue without notifications
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidNotificationChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_reminders',
      'Medicine Reminders',
      description: 'Reminders to take your medicine',
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reminder'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final granted = await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
      return granted;
    } else if (Platform.isAndroid) {
      // Request exact alarm permission for Android 12+
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final canSchedule = await androidImplementation.canScheduleExactNotifications() ?? false;

        if (!canSchedule) {
          await androidImplementation.requestExactAlarmsPermission();
        }
      }

      return true; // Android notifications work by default on older versions
    }
    return true;
  }

  /// Schedule all reminders for a medicine
  Future<void> scheduleRemindersForMedicine(
      Map<String, dynamic> medicine) async {
    try {
      // Calculate reminder times
      final times = ReminderCalculator.calculateReminderTimes(
        medicine,
        throwOnError: true,
      );

      if (times == null || times.isEmpty) {
        print('No reminder times calculated for medicine ${medicine['medicineName']}');
        return;
      }

      final medicineId = medicine['id'] as String;
      final medicineName = medicine['medicineName'] as String;

      print('Scheduling ${times.length} reminders for $medicineName');

      // Schedule each reminder
      for (final time in times) {
        await _scheduleNotification(
          medicineId: medicineId,
          medicineName: medicineName,
          scheduledTime: time,
        );
      }

      print('Successfully scheduled ${times.length} reminders for $medicineName');
    } catch (e) {
      print('Error scheduling reminders: $e');
      rethrow;
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
  }) async {
    // Determine slot from time
    final slot = ReminderCalculator.getSlotForTime(scheduledTime) ?? 'reminder';

    // Create payload
    final payload = jsonEncode({
      'type': 'medicine_reminder',
      'medicineId': medicineId,
      'medicineName': medicineName,
      'slot': slot,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
    });

    // Generate deterministic notification ID
    final notificationId = _generateNotificationId(medicineId, scheduledTime);

    // Convert to timezone-aware datetime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Android notification details
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reminder'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'reminder.wav',
    );

    // Combined notification details
    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Time to take $medicineName',
      'Your $slot dose is ready. Tap to mark as taken.',
      tzScheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('Scheduled notification $notificationId for $medicineName at $scheduledTime');
  }

  /// Cancel all reminders for a specific medicine
  Future<void> cancelRemindersForMedicine(String medicineId) async {
    try {
      // Get all pending notifications
      final pending = await _notificationsPlugin.pendingNotificationRequests();

      // Cancel matching notifications
      int cancelledCount = 0;
      for (final notification in pending) {
        final payload = notification.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            if (data['medicineId'] == medicineId) {
              await _notificationsPlugin.cancel(notification.id);
              cancelledCount++;
            }
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
      }

      print('Cancelled $cancelledCount reminders for medicine $medicineId');
    } catch (e) {
      print('Error cancelling reminders: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('Cancelled all notifications');
  }

  /// Get all pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Generate deterministic notification ID from medicine ID and time
  int _generateNotificationId(String medicineId, DateTime time) {
    // Combine medicineId hash with timestamp to create unique but deterministic ID
    return (medicineId.hashCode ^ time.millisecondsSinceEpoch).toUnsigned(31);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) {
      print('Notification tapped with no payload');
      return;
    }

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      print('Notification tapped: $data');

      if (data['type'] == 'medicine_reminder') {
        print('Medicine reminder tapped for: ${data['medicineName']}');

        // Navigate to dose confirmation page
        if (onNotificationTap != null) {
          onNotificationTap!(
            '/doseConfirmationPage',
            {
              'medicineId': data['medicineId'].toString(),
              'medicineName': data['medicineName'].toString(),
              'slot': data['slot'].toString(),
              'scheduledTime': data['scheduledTime'].toString(),
            },
          );
        } else {
          print('Warning: onNotificationTap callback not set');
        }
      }
    } catch (e) {
      print('Error handling notification tap: $e');
    }
  }

  /// Re-initialize timezone (useful when app resumes after timezone change)
  Future<void> refreshTimezone() async {
    try {
      tz_data.initializeTimeZones();
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      print('Timezone refreshed to: $currentTimeZone');
    } catch (e) {
      print('Error refreshing timezone: $e');
    }
  }
}
