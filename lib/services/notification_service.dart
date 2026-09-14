import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> notifyIfLowStock(Product product) async {
    if (!product.isLowStock) return;

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notificationsEnabled') ?? true;
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'stock_alerts',
      'Alertes de stock',
      channelDescription: 'Notifications de stock bas',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      product.id ?? 0,
      'Stock faible : ${product.name}',
      'Il ne reste que ${product.quantity} unité(s) en stock.',
      details,
    );
  }
}
