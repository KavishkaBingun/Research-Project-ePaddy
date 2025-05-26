import 'dart:convert';
import 'dart:math';

import 'package:epaddy_mobile/ui/views/camera_screen.dart';
import 'package:epaddy_mobile/ui/views/camera_screen_1.dart';
import 'package:epaddy_mobile/ui/views/camera_screen_2.dart';
import 'package:epaddy_mobile/ui/views/history_screen.dart';
import 'package:epaddy_mobile/ui/views/irrigation_control_screen.dart';
import 'package:epaddy_mobile/ui/views/profile_screen.dart';
import 'package:epaddy_mobile/ui/views/soil_status_screen.dart';
import 'package:epaddy_mobile/ui/views/splash_screen.dart';
import 'package:epaddy_mobile/core/service/background_service.dart'; // ✅ Import background service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _temperature = "Loading...";
  String _weatherCondition = "Fetching...";
  String _location = "Detecting...";
  String _highLowTemp = "--° / --°";
  IconData _weatherIcon = Icons.cloud;

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // ✅ Fetch location on startup
  }

  // ✅ Get Mobile Device Location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = "Location services disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = "Location permanently denied";
      });
      return;
    }

    // ✅ Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // ✅ Fetch Weather Data using this location
    fetchWeatherData(position.latitude, position.longitude);
  }

  // ✅ Fetch Weather Data from API
  Future<void> fetchWeatherData(double latitude, double longitude) async {
    const String apiKey = "UL22EcURLIT1WxDsEVwmSCjuSBSORxeM";
    String weatherUrl =
        "https://api.tomorrow.io/v4/weather/realtime?location=$latitude,$longitude&apikey=$apiKey";

    try {
      final response = await http.get(Uri.parse(weatherUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> weatherData = json.decode(response.body);
        final weatherValues = weatherData['data']['values'];

        // ✅ Extract Weather Details
        double temp = weatherValues['temperature'] ?? 0.0;
        double highTemp = temp + Random().nextDouble() * 3; // Fake high temp
        double lowTemp = temp - Random().nextDouble() * 3; // Fake low temp
        int weatherCode =
            weatherValues['weatherCode'] ?? 1000; // Default: Clear
        String weatherDesc = getWeatherDescription(weatherCode);
        IconData weatherIcon = getWeatherIcon(weatherCode);
        // ✅ Get Location Name (Fallback if API fails)
        String locationName =
            weatherData['location']?['name'] ?? "Unknown Location";

        // ✅ Handle missing location properly
        if (locationName == "Unknown Location") {
          locationName = await getCityNameFromCoordinates(latitude, longitude);
        }

        // ✅ Update UI
        setState(() {
          _temperature = "${temp.toStringAsFixed(1)}°C";
          _highLowTemp =
              "H:${highTemp.toStringAsFixed(1)}° L:${lowTemp.toStringAsFixed(1)}°";
          _weatherCondition = weatherDesc;
          _weatherIcon = weatherIcon;
          _location = locationName;
        });
      } else {
        setState(() {
          _temperature = "Error";
          _weatherCondition = "Unable to fetch data";
        });
      }
    } catch (e) {
      print("❌ Error fetching weather: $e");
      setState(() {
        _temperature = "Error";
        _weatherCondition = "No Internet";
      });
    }
  }

  // ✅ Get City Name from Coordinates (Fallback)
  Future<String> getCityNameFromCoordinates(
      double latitude, double longitude) async {
    String url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            "Unknown Location";
      }
    } catch (e) {
      print("❌ Error getting city name: $e");
    }

    return "Unknown Location";
  }

  // ✅ Get Weather Description based on API weatherCode
  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 1000:
        return "Clear Sky";
      case 1100:
        return "Partly Cloudy";
      case 1001:
        return "Cloudy";
      case 1101:
        return "Mostly Cloudy";
      case 2000:
        return "Foggy";
      case 2100:
        return "Light Fog";
      case 4000:
        return "Drizzle";
      case 4200:
        return "Light Rain";
      case 4001:
        return "Rain";
      case 4201:
        return "Heavy Rain";
      case 5000:
        return "Snow";
      case 5100:
        return "Light Snow";
      default:
        return "Normal";
    }
  }

  // ✅ Get Weather Icon based on API weatherCode
  IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 1000:
        return Icons.wb_sunny; // ☀️ Clear
      case 1100:
        return Icons.wb_sunny; // 🌤 Partly Cloudy
      case 1001:
      case 1101:
        return Icons.cloud; // ☁️ Cloudy
      case 2000:
      case 2100:
        return Icons.foggy; // 🌫 Fog
      case 4000:
      case 4200:
        return Icons.grain; // 🌧 Drizzle
      case 4001:
      case 4201:
        return Icons.beach_access; // 🌧 Rain
      case 5000:
      case 5100:
        return Icons.ac_unit; // ❄ Snow
      default:
        return Icons.help_outline; // ❓ Unknown
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == "Profile") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              } else if (value == "Logout") {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: "Profile",
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.green),
                  title: Text("Profile"),
                ),
              ),
              const PopupMenuItem<String>(
                value: "Logout",
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather info section
            // ✅ Weather Info Section (Updated)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_temperature,
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold)),
                      Text(_highLowTemp, style: const TextStyle(fontSize: 16)),
                      Text(_location, style: const TextStyle(fontSize: 16)),
                      Text(_weatherCondition,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Icon(_weatherIcon, size: 80, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Main Features Title
            const Text(
              'Main Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Main Features Grid (Cards with button-like style)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              children: [
                FeatureCard(
                  icon: Icons.search,
                  title: 'Diagnose your crop',
                  buttonText: 'Diagnose Diseases',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen2()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.nature_outlined,
                  title: 'Follow your soil status',
                  buttonText: 'Predict & Recommends',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SoilStatusScreen()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Control & save water',
                  buttonText: 'Manage Irrigation',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const IrrigationControlScreen()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.satellite_alt,
                  title: 'Crop phase monitor',
                  buttonText: 'Monitor Growth',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.bug_report,
                  title: 'Pest identification',
                  buttonText: 'Identify Pests',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraScreen1()),
                    );
                  },
                ),
                // ✅ New Feature: Trigger Weather Data Fetch & Notification
                FeatureCard(
                  icon: Icons.cloud_sync,
                  title: 'Get Weather Alert',
                  buttonText: 'Check Now',
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fetching weather data...")),
                    );

                    await fetchWeatherDataAndSendToML(); // ✅ Trigger the function
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Keep Home as the default index
        onTap: (index) {
          if (index == 1) {
            // Only navigate when History is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ✅ FeatureCard Widget
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(15),
                child: Icon(icon, size: 40, color: Colors.green),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
