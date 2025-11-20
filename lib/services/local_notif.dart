import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// requires flutter_local_notifications package :)
class LocalNotif {
  static final FlutterLocalNotificationsPlugin _notif =
  FlutterLocalNotificationsPlugin();

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'obppay_channel',
      'ObpPay Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,        // 🔥 Makes it persistent
      playSound: true,
    );

    const NotificationDetails details =
    NotificationDetails(android: androidDetails);

    await _notif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
