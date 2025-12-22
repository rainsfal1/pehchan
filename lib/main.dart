import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workmanager/workmanager.dart';

import 'src/ui/styles/pillkaboo_theme.dart';
import 'src/core/internationalization.dart';
import 'src/nav/nav.dart';
import 'src/data/local/shared_preference/app_state.dart';
import 'src/app/background_service.dart';
import 'src/app/app_lifecycle_reactor.dart';
import 'src/data/local/database/barcode_db_helper.dart';
import 'src/data/local/database/ingredients_db_helper.dart';
import 'src/app/notification_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    checkAndUpdateData();
    return Future.value(true);
  });
}

// Initialize notification service asynchronously (non-blocking)
void _initializeNotifications() {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Failed to initialize NotificationService: $e');
      // Continue app execution even if notifications fail
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding.instance.addObserver(AppLifecycleReactor());
  usePathUrlStrategy();

  await PillKaBooTheme.initialize();

  // Initialize databases
  await BarcodeDBHelper.database;
  await IngredientsDBHelper.database;

  // request permission
  await Permission.camera.request();

  final appState = PKBAppState();
  await appState.initializePersistedState();

  // Initialize notification service (non-blocking)
  _initializeNotifications();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: const MyApp(),
  ));

  if (Platform.isAndroid) {
    Workmanager().registerPeriodicTask(
      "1",
      "periodicUpdateTask",
      frequency: const Duration(hours: 24 * 7),
    );
  }

  //PKBAppState().isFirstLaunch = true;

  //print(PKBAppState().isFirstLaunch);


}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = PillKaBooTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  bool displaySplashImage = true;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    // Set up notification tap handler
    NotificationService().onNotificationTap = (route, params) {
      final uri = Uri(path: route, queryParameters: params);
      _router.go(uri.toString());
    };

    Future.delayed(const Duration(milliseconds: 1000),
            () => setState(() => _appStateNotifier.stopShowingSplashImage()));
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    PillKaBooTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PKBAppState>(builder: (context, appState, _) {
      return MaterialApp.router(
        title: 'Pehchan',
        localizationsDelegates: const [
          PKBLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        locale: _locale ?? const Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('ur'),
        ],
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(appState.textScale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: _themeMode,
        routerConfig: _router,
      );
    });
  }
}
