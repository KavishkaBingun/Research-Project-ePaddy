import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/service/api_service.dart';
import '../../core/service/firestore_service.dart';
import 'prediction_screen.dart';

class SoilStatusScreen extends StatefulWidget {
  const SoilStatusScreen({super.key});

  @override
  _SoilStatusScreenState createState() => _SoilStatusScreenState();
}

class _SoilStatusScreenState extends State<SoilStatusScreen> {
  final _apiService = ApiService();
  final _firestoreService = FirestoreService();
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  bool _isLoading = false;
  String? predictedCrop;
  double? accuracy;
  Map<String, dynamic>? _latestSoilData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchSoilData();

    // ✅ Fetch Data Every 5 Seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchSoilData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    super.dispose();
  }

  // 🔹 Fetch latest soil data from Firestore every 5 seconds
  Future<void> _fetchSoilData() async {
    try {
      final data = await _firestoreService.getLatestSoilData();
      if (data != null) {
        setState(() {
          _latestSoilData = data;
        });
        print("🔥 Latest Soil Data: $_latestSoilData"); // Debugging
      } else {
        print("⚠️ No soil data found.");
      }
    } catch (e) {
      print("❌ Error fetching soil data: $e");
    }
  }

  // 🔹 Handle Predict & Save
  Future<void> _predictAndSave() async {
    final int? nitrogen = int.tryParse(_nController.text);
    final int? phosphorus = int.tryParse(_pController.text);
    final int? potassium = int.tryParse(_kController.text);

    if (nitrogen == null || phosphorus == null || potassium == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter valid NPK values")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔹 Call API for Prediction
      final result = await _apiService.getCropRecommendation(nitrogen, phosphorus, potassium);
      setState(() {
        predictedCrop = result["predicted_label"];
        accuracy = result["accuracy_percentage"];
      });

      // 🔹 Save to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("cropRecommend").add({
          "userId": user.uid,
          "nitrogen": nitrogen,
          "phosphorus": phosphorus,
          "potassium": potassium,
          "predictedCrop": predictedCrop,
          "accuracy": accuracy,
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      // 🔹 Navigate to Prediction Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionScreen(
            cropName: predictedCrop!,
            nitrogen: nitrogen,
            phosphorus: phosphorus,
            potassium: potassium,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Soil Status"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView( // ✅ Makes the page scrollable
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/soilStatus.png',
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Display Latest Soil Data if Available
              _latestSoilData != null
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InfoCard(label: "Nitrogen", value: _latestSoilData?["nitrogen"]?.toString() ?? "N/A"),
                            InfoCard(label: "Phosphorus", value: _latestSoilData?["phosphorous"]?.toString() ?? "N/A"),
                            InfoCard(label: "Potassium", value: _latestSoilData?["potassium"]?.toString() ?? "N/A"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InfoCard(label: "Moisture", value: _latestSoilData?["moisture"]?.toString() ?? "N/A"),
                            InfoCard(label: "EC", value: _latestSoilData?["ec"]?.toString() ?? "N/A"),
                            InfoCard(label: "pH", value: _latestSoilData?["ph"]?.toString() ?? "N/A"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        InfoCard(label: "Temperature", value: _latestSoilData?["temperature"]?.toString() ?? "N/A"),
                      ],
                    )
                  : const Text("⚠️ No soil data available."),

              const SizedBox(height: 20),

              // 🔹 NPK Input Fields
              TextField(
                controller: _nController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter Nitrogen (N) Value"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter Phosphorus (P) Value"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _kController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Enter Potassium (K) Value"),
              ),
              const SizedBox(height: 20),

              // 🔹 Predict Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                onPressed: _isLoading ? null : _predictAndSave,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Predict and Recommend",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Custom InfoCard Widget
class InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const InfoCard({required this.label, required this.value, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
