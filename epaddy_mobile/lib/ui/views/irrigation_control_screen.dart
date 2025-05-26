import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/service/firestore_service.dart';

class IrrigationControlScreen extends StatefulWidget {
  const IrrigationControlScreen({super.key});

  @override
  State<IrrigationControlScreen> createState() =>
      _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic>? _waterLevelData;
  bool _isManualMode = false; // 🔹 Track current mode
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchWaterLevelData();

    // 🔄 Refresh data every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchWaterLevelData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🔹 Fetch latest water level
  Future<void> _fetchWaterLevelData() async {
    final data = await _firestoreService.getLatestWaterLevelData();
    if (data != null) {
      setState(() {
        _waterLevelData = data;
      });
      print("🔥 Latest Water Level Data: $_waterLevelData");
    } else {
      print("⚠️ No water level data found.");
    }
  }

  // 🔹 Update mode & motor direction in Firestore
  Future<void> _updateControlModeAndDirection({
    required String mode,
    String direction = 'stop',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('Waterlevel_data')
        .doc('liveControl')
        .set({'mode': mode, 'motorDirection': direction},
            SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    int waterLevel =
        int.tryParse(_waterLevelData?['waterLevel']?.toString() ?? "0") ?? 0;
    int reversedWaterLevel =
        (waterLevel > 0 && waterLevel <= 25) ? (26 - waterLevel) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Irrigation Control"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Calendar
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: _focusedDay,
                lastDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Water Level Info
              _waterLevelData != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _infoCard("Water Level", "", "$waterLevel cm"),
                        _infoCard(
                            "Reversed Level", "", "$reversedWaterLevel cm"),
                        _infoCard("Gate Status", "",
                            "${_waterLevelData?['gateStatus'] ?? 'N/A'}"),
                      ],
                    )
                  : const Text("⚠️ No water level data available"),

              const SizedBox(height: 30),

              // 🔹 Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Automatic"),
                  Switch(
                    value: _isManualMode,
                    onChanged: (val) async {
                      setState(() => _isManualMode = val);
                      await _updateControlModeAndDirection(
                          mode: val ? 'manual' : 'auto', direction: 'stop');
                    },
                  ),
                  const Text("Manual"),
                ],
              ),

              if (_isManualMode) ...[
                const SizedBox(height: 10),

                // 🔹 UP Button
                GestureDetector(
                  onTapDown: (_) => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'forward'),
                  onTapUp: (_) => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'stop'),
                  onTapCancel: () => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'stop'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade200,
                    ),
                    child: const Icon(Icons.arrow_upward, size: 32),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔹 DOWN Button
                GestureDetector(
                  onTapDown: (_) => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'reverse'),
                  onTapUp: (_) => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'stop'),
                  onTapCancel: () => _updateControlModeAndDirection(
                      mode: 'manual', direction: 'stop'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade200,
                    ),
                    child: const Icon(Icons.arrow_downward, size: 32),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Info Card
  Widget _infoCard(String title, String subtitle, String value) {
    return Container(
      width: 110,
      height: 90,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: const TextStyle(fontSize: 8, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(fontSize: 16, color: Colors.green)),
        ],
      ),
    );
  }
}
