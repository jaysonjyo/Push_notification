import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';
import 'notification_page.dart';


// go to firebase selecte encage option
// select messaging and paste FCMToken and paste it and press add button
// each user
class FirebaseApi {
  final _firebasemessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage([RemoteMessage? message]) async {
    print('Title:${message?.notification?.title}');
    print('Body:${message?.notification?.body}');
    print('Payload:${message?.data}');
  }

  Future<void> initNotificatios() async {
    await _firebasemessaging.requestPermission();
    final FCMToken = await _firebasemessaging.getToken();
    print("Token:$FCMToken");
    //for pushing notification
    initPushNotification();
  }
  void handleMessage(RemoteMessage? message) {
    if (message == null) {
      return;
    }
    navigatorKey.currentState
        ?.pushNamed(NotificationScreen.route, arguments: message);
  }
  Future<void> initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(
            (message) => handleBackgroundMessage(message));
    FirebaseMessaging.onMessage.listen((message) {
      final notifications = message.notification;
      if (notifications == null) return;
      _localNotifications.show(
          notifications.hashCode,
          notifications.title,
          notifications.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                androidChannel.id, androidChannel.name,
                channelDescription: androidChannel.description,
                icon: '@drawable/ic_launcher'),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }
  final androidChannel = AndroidNotificationChannel(
      'high_importance_channel', 'High_Importance_Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('app_icon');
    const settings = InitializationSettings(android: android);

    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    await localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        final payload = notificationResponse.payload;
        if (payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(payload));
          handleMessage(message);
        }
      },
    );
  }


}