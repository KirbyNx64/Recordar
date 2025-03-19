import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await requestExactAlarmPermission();
  tz.initializeTimeZones(); // Inicializa las zonas horarias
  await initializeNotifications(); // Asegura que las notificaciones estén listas antes de seguir
  await requestExactAlarmPermission(); // Asegura que los permisos estén dados

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  print('🔍 Solicitando permisos de notificación...');
  
  var status = await Permission.notification.status;
  print('🔍 Estado actual: $status');

  if (status.isDenied || status.isPermanentlyDenied) {
    print('🛑 Permiso denegado, solicitando...');
    var newStatus = await Permission.notification.request();
    print('🔄 Nuevo estado: $newStatus');
  } else {
    print('✅ Permiso ya concedido.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App Flutter',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      home: const Material3BottomNav(), // Muestra la Home Page primero
    );
  }
}

class Material3BottomNav extends StatefulWidget {
  const Material3BottomNav({super.key});

  @override
  State<Material3BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<Material3BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const Center(child: Text("Buscar", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Notificaciones", style: TextStyle(fontSize: 20))),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _solicitarPermisoNotificaciones(); // Pide permiso después de mostrar la home
  }

  Future<void> _solicitarPermisoNotificaciones() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: _navBarItems,
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(icon: Icon(Icons.home_outlined, size: 30), selectedIcon: Icon(Icons.home_rounded, size: 30), label: 'Inicio'),
  NavigationDestination(icon: Icon(Icons.search_outlined, size: 30), selectedIcon: Icon(Icons.search_rounded, size: 30), label: 'Buscar'),
  NavigationDestination(icon: Icon(Icons.notifications_outlined, size: 30), selectedIcon: Icon(Icons.notifications_rounded, size: 30), label: 'Notificaciones'),
  NavigationDestination(icon: Icon(Icons.person_outline_rounded, size: 30), selectedIcon: Icon(Icons.person_rounded, size: 30), label: 'Perfil'),
];
