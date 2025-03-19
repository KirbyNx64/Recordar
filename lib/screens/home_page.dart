import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'reminder.dart';
import 'add_reminder_page.dart';
import 'edit_reminder_page.dart';
import '../notifications_service.dart'; // Importamos el servicio de notificaciones

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {
  String userName = "Usuario";
  List<Reminder> reminders = [];

  Map<int, bool> notificationStatus = {};

  @override
  void initState() {
    super.initState();
    requestExactAlarmPermission(); 
    requestNotificationPermission();
    _loadUserName();
    _loadReminders();
    _loadNotificationStatus();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "Usuario";
    });
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? reminderList = prefs.getStringList('reminders');

    if (reminderList != null) {
      setState(() {
        reminders = reminderList.map((reminder) {
          return Reminder.fromMap(jsonDecode(reminder));
        }).toList();
      });
    }
  }

  Future<void> _loadNotificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < reminders.length; i++) {
        notificationStatus[i] = prefs.getBool('notification_$i') ?? true;
      }
    });
  }

  Future<void> _saveNotificationStatus(int index, bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notification_$index', status);
  }

  Future<void> _toggleNotification(int index, bool isActive) async {
    print('🔔 Cambiando notificación para recordatorio $index - Estado: $isActive');

    setState(() {
      notificationStatus[index] = isActive;
    });
    await _saveNotificationStatus(index, isActive);

    if (isActive) {
      print('⏳ Programando notificación para: ${reminders[index].dateTime}');
      await scheduleNotification(
        index,
        reminders[index].name,
        reminders[index].description,
        reminders[index].dateTime,
        minutosAntes: 5,
      );
      print('✅ Notificación programada');
    } else {
      print('❌ Cancelando notificación para ID: $index');
      await cancelNotification(index);
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _addReminder(Reminder reminder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reminders.add(reminder);
    });

    List<String> reminderList = reminders.map((r) => jsonEncode(r.toMap())).toList();
    prefs.setStringList('reminders', reminderList);

    // Programar la notificación
    await scheduleNotification(
      reminders.indexOf(reminder), // 🔹 Usa el índice real del recordatorio
      reminder.name,
      reminder.description,
      reminder.dateTime,
    );

    await checkPendingNotifications();
  }

  Future<void> _deleteReminder(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reminders.removeAt(index);
    });

    List<String> reminderList = reminders.map((r) => jsonEncode(r.toMap())).toList();
    prefs.setStringList('reminders', reminderList);
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return "Buenos días";
    } else if (hour >= 12 && hour < 18) {
      return "Buenas tardes";
    } else {
      return "Buenas noches";
    }
  }

  void _confirmDeleteReminder(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar recordatorio"),
          content: const Text("¿Estás seguro de que deseas eliminar este recordatorio?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _deleteReminder(index);
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _editReminder(int index) async {
    final editedReminder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminder: reminders[index]),
      ),
    );

    if (editedReminder != null) {
      setState(() {
        reminders[index] = editedReminder;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> reminderList = reminders.map((r) => jsonEncode(r.toMap())).toList();
      prefs.setStringList('reminders', reminderList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Recordatorios")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName == "Usuario" ? getGreeting() : "👋🏻 ¡${getGreeting()}, $userName!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: reminders.isEmpty
                  ? const Center(child: Text("No hay recordatorios aún."))
                  : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];

                        String formattedDate = DateFormat('dd-MM-yyyy').format(reminder.dateTime);
                        String formattedTime = DateFormat('hh:mm a').format(reminder.dateTime);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        reminder.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.grey),
                                          onPressed: () => _confirmDeleteReminder(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.grey),
                                          onPressed: () => _editReminder(index),
                                        ),
                                        Switch(
                                          value: notificationStatus[index] ?? true,
                                          onChanged: (value) => _toggleNotification(index, value),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4), // Reducido para optimizar espacio
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 5),
                                    Text(formattedDate),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 5),
                                    Text(formattedTime),
                                  ],
                                ),
                                if (reminder.place.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 5),
                                      Expanded(child: Text(reminder.place)),
                                    ],
                                  ),
                                if (reminder.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.description, size: 16),
                                            SizedBox(width: 5),
                                            Text("Descripción:"),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(reminder.description),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );

                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final Reminder? newReminder = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddReminderPage()),
              );

              if (newReminder != null) {
                _addReminder(newReminder);

                // 🔔 Programar una notificación de prueba 10 segundos después de agregar un recordatorio
                DateTime ahora = DateTime.now().add(Duration(seconds: 10));
                print('🔔 Programando notificación de prueba para: $ahora');

                await scheduleNotification(
                  9999, // ID temporal para la prueba
                  'Recordatorio de Prueba',
                  'Este es un test de notificación.',
                  ahora,
                  minutosAntes: 0, // Se programa exactamente en 10 segundos
                );
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10), // Espaciado entre botones
          FloatingActionButton(
            onPressed: () {
              testInstantNotification(); // 🔹 Llama la función de prueba inmediata
            },
            backgroundColor: Colors.red, // Diferente color para identificarlo
            child: const Icon(Icons.notifications_active),
          ),
        ],
      ),
    );
  }
}
