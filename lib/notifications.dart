import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';

//const String darwinNotificationCategoryPlain = 'plainCategory';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _startForegroundService() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('care_reminder', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.startForegroundService(1, 'plain title', 'plain body',
          notificationDetails: androidPlatformChannelSpecifics,
          payload: 'item x');
}

void _requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

}

Future<void> _createNotificationChannel(
    String channelId, String channelName, String channelDescription) async {
  AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);
}

void initNotifications(String channelName, String channelDescription) async {
  //_startForegroundService();
  _requestPermissions();
  _createNotificationChannel("care_reminder", channelName, channelDescription);
  //_createNotificationChannelGroup();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_stat_florae');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        // notificationCategories: [
        //   DarwinNotificationCategory(darwinNotificationCategoryPlain,
        //      actions: <DarwinNotificationAction>[
        //       DarwinNotificationAction.plain('id_1', 'Action 1'),
        //     ]
        //   )
        // ]
      );

  const InitializationSettings initializationSettings =
      InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future singleNotification(String title, String body, int hashCode,
    {String? payload, String? sound}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('care_reminder', 'Care reminder',
          icon: '@drawable/ic_stat_florae',
          channelDescription: 'Receive plants care notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'care_reminder');

  const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
          //categoryIdentifier: darwinNotificationCategoryPlain
      );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin
      .show(hashCode, title, body, platformChannelSpecifics, payload: payload);
}
