import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Registers this device for push notifications and keeps the FCM
/// token saved on the user's Firestore profile so the
/// `sendOrderStatusNotification` Cloud Function knows where to deliver
/// pushes (see `functions/index.js`).
///
/// Call `NotificationService.instance.init()` once, right after a
/// successful sign-in — see `MainShell`'s `initState`.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // iOS/Android 13+ both require an explicit runtime permission
    // prompt before any notification (local or push) can show.
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _saveTokenToFirestore();
    // Re-save whenever Firebase rotates the token (happens occasionally).
    _messaging.onTokenRefresh.listen((_) => _saveTokenToFirestore());

    // Foreground messages don't show a system banner by default on
    // Android — show one ourselves via flutter_local_notifications so
    // an order-status push is visible even while the app is open.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'order_updates',
            'Order Updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<void> _saveTokenToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  /// Called on sign-out so a shared/borrowed device doesn't keep
  /// receiving another person's order notifications.
  Future<void> clearTokenOnSignOut(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'fcmToken': FieldValue.delete()});
    } catch (_) {
      // Best-effort — not worth blocking sign-out over.
    }
  }
}
