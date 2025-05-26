import 'dart:convert';
import 'package:epaddy_mobile/core/service/background_service.dart';
import 'package:epaddy_mobile/firebase_options.dart';
import 'package:epaddy_mobile/ui/views/login_screen.dart';
import 'package:epaddy_mobile/ui/views/signup_screen.dart';
import 'package:epaddy_mobile/ui/views/alert_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'ui/views/splash_screen.dart';
import 'ui/views/home_screen.dart';
import 'ui/theme/colors.dart';

// ✅ Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background Notification Received: ${message.data}");

  // ✅ Ensure JSON is properly formatted before opening Alert Page
  try {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => AlertScreen(
          notificationData: message.data.isNotEmpty ? message.data : {},
        ),
      ),
    );
  } catch (e) {
    print("❌ Error navigating to Alert Screen: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Handle Background Notification Clicks
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Request Permissions (iOS Only)
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ Get APNs Token (iOS Only)
    String? apnsToken = await messaging.getAPNSToken();
    print("📲 APNS Token: $apnsToken");

    // ✅ Subscribe user to topic
    await messaging.subscribeToTopic("weather-alerts");

    // ✅ Initialize Local Notifications
    await initializeLocalNotifications();

    // ✅ Register Background Task for Weather Updates
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    // Workmanager().registerPeriodicTask(
    //   "fetchWeatherTask",
    //   fetchWeatherTask,
    //   frequency: const Duration(minutes: 10),
    // );

    // ✅ Register Water Level Monitoring Task (Every 5 Minutes)
    Workmanager().registerPeriodicTask(
      fetchWaterLevelTask,
      "Monitor Water Levels",
      frequency: const Duration(minutes: 5),
    );

    // ✅ Handle Foreground Notifications (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground Notification: ${message.data}");

      // ✅ Show local notification
      _showLocalNotification(message.data);

      // ✅ Navigate when notification is clicked
      _navigateToAlertScreen(message.data);
    });

    // ✅ Handle Notification Clicks (when app is in background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 Notification Clicked: ${message.data}");
      _navigateToAlertScreen(message.data);
    });

    // ✅ Start Flutter App
    runApp(const MyApp());
  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
  }
}

// ✅ Initialize Local Notifications
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null && response.payload!.isNotEmpty) {
        try {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          _navigateToAlertScreen(data);
        } catch (e) {
          print("❌ Error parsing notification data: $e");
        }
      }
    },
  );
}

// ✅ Function to Show Local Notification
void _showLocalNotification(Map<String, dynamic> mlResponse) {
  String? jsonPayload;
  try {
    jsonPayload = jsonEncode(mlResponse);
  } catch (e) {
    print("❌ JSON Encoding Error: $e");
    jsonPayload = "{}";
  }

  flutterLocalNotificationsPlugin.show(
    0,
    "🌾 Disease Alert!",
    "Predicted Disease: ${mlResponse['Prediction']} (Confidence: ${mlResponse['Confidence']}%)",
    NotificationDetails(
      android: AndroidNotificationDetails(
        'weather_alert_channel',
        'Weather Alerts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: jsonPayload, // ✅ Pass correct payload
  );
}

// ✅ Function to Navigate to Alert Screen
void _navigateToAlertScreen(Map<String, dynamic> data) {
  Future.delayed(Duration.zero, () {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => AlertScreen(notificationData: data),
        ),
      );
    } else {
      print("⚠ navigatorKey is NULL, could not navigate");
    }
  });
}

// ✅ Flutter App with Global Navigator Key
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ Set Global Navigator Key
      title: 'ePaddy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
