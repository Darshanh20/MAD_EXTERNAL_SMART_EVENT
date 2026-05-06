import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/event.dart';
import 'models/participant.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/events_list_screen.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(EventAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ParticipantAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Open boxes with error handling for corrupt data
  try {
    await Hive.openBox<Event>('events');
  } catch (e) {
    await Hive.deleteBoxFromDisk('events');
    await Hive.openBox<Event>('events');
  }

  try {
    await Hive.openBox<Participant>('participants');
  } catch (e) {
    await Hive.deleteBoxFromDisk('participants');
    await Hive.openBox<Participant>('participants');
  }

  try {
    await Hive.openBox<User>('users');
  } catch (e) {
    await Hive.deleteBoxFromDisk('users');
    await Hive.openBox<User>('users');
  }

  try {
    await Hive.openBox<String>('session');
  } catch (e) {
    await Hive.deleteBoxFromDisk('session');
    await Hive.openBox<String>('session');
  }

  await AuthService.instance.init();
  await SyncService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: const EVENTLYApp(),
    ),
  );
}

class EVENTLYApp extends StatelessWidget {
  const EVENTLYApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
    ).copyWith(primary: Colors.teal, secondary: Colors.deepPurple);

    return MaterialApp(
      title: 'EVENTLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        cardTheme: CardThemeData(
          color: scheme.surface,
          surfaceTintColor: scheme.surfaceTint,
          elevation: 0,
        ),
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isLoggedIn) {
      return const EventsListScreen();
    }
    return const RoleSelectionScreenInitial();
  }
}
