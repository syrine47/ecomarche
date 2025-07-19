import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ✅ Plus besoin de BuildContext ici
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Gère la navigation ou d'autres actions ici
          print("Payload reçu : ${response.payload}");
        }
      },
    );
  }

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload, // ✅ Ajout du paramètre payload optionnel
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel', // ID de canal
      'Notifications EcoMarché', // Nom du canal
      channelDescription: 'Notifications pour les nouveaux produits et marchés',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload ?? 'eco_payload', // ✅ Utilise le payload personnalisé ou le défaut
    );
  }
}