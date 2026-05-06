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
    const background = Color(0xFF0B0C10);
    const surface = Color(0xFF11141A);
    const surfaceAlt = Color(0xFF1A1E25);
    const surfaceMuted = Color(0xFF15181E);
    const cream = Color(0xFFF3E6C2);
    const sand = Color(0xFFD9CDB0);
    const outline = Color(0xFF303642);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: cream,
          brightness: Brightness.dark,
        ).copyWith(
          primary: cream,
          onPrimary: background,
          primaryContainer: const Color(0xFF2A2418),
          onPrimaryContainer: cream,
          secondary: sand,
          onSecondary: background,
          secondaryContainer: const Color(0xFF262A31),
          onSecondaryContainer: cream,
          tertiary: const Color(0xFF9AA2AE),
          background: background,
          onBackground: const Color(0xFFF4F0E6),
          surface: surface,
          onSurface: const Color(0xFFF4F0E6),
          surfaceTint: cream,
          surfaceContainerLow: const Color(0xFF0F1116),
          surfaceContainer: surfaceMuted,
          surfaceContainerHigh: const Color(0xFF171A20),
          surfaceContainerHighest: surfaceAlt,
          outline: outline,
          outlineVariant: const Color(0xFF232933),
          error: const Color(0xFFFF8B8B),
          errorContainer: const Color(0xFF3D1F22),
          onError: background,
          onErrorContainer: const Color(0xFFFFD6D9),
          inverseSurface: const Color(0xFFF2EBDD),
          inversePrimary: const Color(0xFF8C7A58),
        );

    return MaterialApp(
      title: 'EVENTLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: scheme.background,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: scheme.background,
          foregroundColor: scheme.onBackground,
          surfaceTintColor: scheme.background,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: scheme.surfaceContainerHigh,
          surfaceTintColor: scheme.surfaceTint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: scheme.surfaceContainerHighest,
            disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
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
