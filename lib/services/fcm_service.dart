import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final notification = msg.notification;
      if (notification != null) {
        print('Foreground notification: ${notification.title}');
      }
    });
  }
}