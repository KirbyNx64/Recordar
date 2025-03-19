import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/El_Salvador'));

  print('🌍 Zona horaria configurada: ${tz.local}');

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Crear canal de notificación
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id',
    'Recordatorios',
    description: 'Canal para recordatorios de la app',
    importance: Importance.max,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    await androidImplementation.createNotificationChannel(channel);
  }

  // Solicitar permisos en Android 13+
  if (Platform.isAndroid) {
    await requestExactAlarmPermission();
  }

  // Prueba de notificación inmediata después de la inicialización
  print("🔍 Probando notificación instantánea después de inicialización...");
  await testInstantNotification();
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.notification.isDenied) {
    print("⚠️ Permiso de notificación denegado, solicitando...");
    await Permission.notification.request();
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    print("⚠️ Permiso de alarma exacta denegado, solicitando...");
    await Permission.scheduleExactAlarm.request();
  }

  print("✅ Permisos verificados.");
}

// Función para mostrar una notificación inmediata
Future<void> mostrarNotificacion() async {
  print("🔔 Mostrando notificación inmediata...");
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Recordatorios',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '🔔 Notificación Instantánea',
    'Este es un recordatorio inmediato.',
    notificationDetails,
  );
}

// Función para programar una notificación
Future<void> scheduleNotification(
    int id, String title, String body, DateTime scheduledTime, {int minutosAntes = 5}) async {
  
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/El_Salvador'));

  DateTime notificationTime = scheduledTime.subtract(Duration(minutes: minutosAntes));

  print('📅 Hora programada original: $scheduledTime');
  print('⏳ Minutos antes: $minutosAntes');
  print('⏳ Hora de notificación ajustada: $notificationTime');
  print('🕒 Hora actual: ${DateTime.now()}');

  if (notificationTime.isBefore(DateTime.now())) {
    print('⚠️ La notificación ya pasó. Se cancela la programación.');
    return;
  }

  print('📢 Intentando programar notificación para $notificationTime');

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Recordatorios',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(notificationTime, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // 🔹 NUEVO PARÁMETRO CORRECTO
  );

  print('✅ Notificación programada con éxito para: $notificationTime');
}

Future<void> requestNotificationPermission() async {
  print('🔍 Solicitando permisos de notificación...');
  
  var status = await Permission.notification.status;
  print('🔍 Estado actual: $status');

  if (status.isDenied || status.isPermanentlyDenied) {
    print('🛑 Permiso denegado, solicitándolo...');
    var newStatus = await Permission.notification.request();
    print('🔄 Nuevo estado: $newStatus');
  } else {
    print('✅ Permiso ya concedido.');
  }
}

Future<void> testInstantNotification() async {
  print("🔔 Enviando notificación instantánea de prueba...");
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Recordatorios',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    1000, // ID aleatorio para prueba
    '🔔 Notificación Instantánea',
    'Si ves esto, las notificaciones funcionan.',
    notificationDetails,
  );
}

Future<void> checkPendingNotifications() async {
  final pendingNotifications =
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  print('📌 Notificaciones pendientes: $pendingNotifications');
}
