import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epaddy_mobile/core/config/api_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart'; // ✅ Import main.dart where `flutterLocalNotificationsPlugin` is defined

const String fetchWeatherTask = "fetchWeatherTask";
const String fetchWaterLevelTask = "fetchWaterLevelTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp();

    if (task == fetchWeatherTask) {
      await fetchWeatherDataAndSendToML();
    } else if (task == fetchWaterLevelTask) {
      await checkWaterLevelAndNotify();
    }
    return Future.value(true);
  });
}

// ✅ Fetch Water Level and Send Notification if Needed
Future<void> checkWaterLevelAndNotify() async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection("waterLevels")
        .doc("latest") // Assuming document name is "latest"
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data();
      if (data != null) {
        int waterLevel = data["waterLevel"] ?? 0;

        if (waterLevel <= 15) {
          await sendWaterLevelNotification(waterLevel);
        }
      }
    }
  } catch (e) {
    print("❌ Error fetching water level: $e");
  }
}

// ✅ Send Local Notification for Water Level
Future<void> sendWaterLevelNotification(int waterLevel) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'water_alert_channel',
    'Water Alerts',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    1, // Unique ID for this notification
    "🚨 High Water Level Alert!",
    "Water gates is open. Please check the paddy.",
    platformDetails,
  );
}


// ✅ Fetch Weather Data and Send to ML Backend
Future<void> fetchWeatherDataAndSendToML() async {
  final String apiKey = "UL22EcURLIT1WxDsEVwmSCjuSBSORxeM";

  // ✅ Get User Location
  Position? position = await getCurrentLocation();
  if (position == null) return;

  String location = "${position.latitude},${position.longitude}";
  String weatherUrl =
      "https://api.tomorrow.io/v4/weather/realtime?location=$location&apikey=$apiKey";

  try {
    final response = await http.get(Uri.parse(weatherUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> weatherData = json.decode(response.body);
      double temperature =
          (weatherData['data']['values']['temperature'] as num?)?.toDouble() ??
              0.0;
      double humidity =
          (weatherData['data']['values']['humidity'] as num?)?.toDouble() ??
              0.0;
      double rainfall =
          (weatherData['data']['values']['precipitationIntensity'] as num?)
                  ?.toDouble() ??
              0.0;

      // ✅ Get Logged-in User ID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user logged in.");
        return;
      }
      String userId = user.uid; // ✅ Get User ID

      // ✅ Send to ML Backend
      Map<String, dynamic> mlResponse =
          await sendToMLBackend(userId, temperature, humidity, rainfall);

      // ✅ Send Push Notification to Mobile
      sendPushNotificationToMobile(mlResponse);
    }
  } catch (e) {
    print("❌ Error fetching weather data: $e");
  }
}

// ✅ Get Device Location
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("❌ Location services are disabled.");
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("❌ Location permissions are denied.");
      return null;
    }
  }

  return await Geolocator.getCurrentPosition();
}

// ✅ Send Weather Data to ML Backend
Future<Map<String, dynamic>> sendToMLBackend(
    String userId, double temperature, double humidity, double rainfall) async {
  const String mlUrl = ApiConstants.riceDisease; // ML Backend URL

  try {
    final response = await http.post(
      Uri.parse(mlUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "Temperature": temperature,
        "Humidity": humidity,
        "Rainfall": rainfall
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Error sending data to ML Backend: ${response.body}");
      return {};
    }
  } catch (e) {
    print("❌ Exception sending data to ML Backend: $e");
    return {};
  }
}

// ✅ Send Push Notification to Mobile
void sendPushNotificationToMobile(Map<String, dynamic> mlResponse) async {
  if (mlResponse.isEmpty) return;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Subscribe user to topic
  await messaging.subscribeToTopic("weather-alerts");

  // ✅ Show Local Notification
  _showLocalNotification(mlResponse);
}

// ✅ Show Local Notification
void _showLocalNotification(Map<String, dynamic> mlResponse) {
  flutterLocalNotificationsPlugin.show(
    0,
    "🌾 Weather Alert!",
    "Predicted Disease: ${mlResponse['prediction']} (Confidence: ${mlResponse['confidence']}%)",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'weather_alert_channel',
        'Weather Alerts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
    ),
  );
}
