import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AlertScreen extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const AlertScreen({Key? key, required this.notificationData}) : super(key: key);

  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  String? recommendation1;
  String? recommendation2;

  @override
  void initState() {
    super.initState();
    fetchRandomRecommendations();
  }

  // ✅ Function to fetch random recommendations from Firestore
  Future<void> fetchRandomRecommendations() async {
    try {
      String diseaseName = widget.notificationData['Prediction'] ?? "Unknown Disease";

      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance.collection('weatherResultRecommendation').doc(diseaseName).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        if (data != null && data.isNotEmpty) {
          List<String> values = data.values.map((value) => value.toString()).toList();

          if (values.length >= 2) {
            values.shuffle(Random()); // Randomize the list
            setState(() {
              recommendation1 = values[0];
              recommendation2 = values[1];
            });
          } else {
            setState(() {
              recommendation1 = values.isNotEmpty ? values[0] : "No data available";
              recommendation2 = values.length > 1 ? values[1] : "No data available";
            });
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching recommendations: $e");
      setState(() {
        recommendation1 = "Error loading data";
        recommendation2 = "Error loading data";
      });
    }
  }

  String getDiseaseImagePath(String diseaseName) {
    switch (diseaseName.toLowerCase()) {
      case "bacterial leaf blight":
        return "assets/images/Bacterialleafblight.jpeg";
      case "brown spot":
        return "assets/images/Brownspot.jpeg";
      case "rice blast":
        return "assets/images/riceblast.jpeg";
      default:
        return "assets/images/default.jpeg"; // fallback image
    }
  }


  @override
  Widget build(BuildContext context) {
    String diseaseName = widget.notificationData['Prediction'] ?? "Unknown Disease";
    String confidence = widget.notificationData['Confidence'] ?? "N/A";
    String temperature = widget.notificationData['Temperature'] ?? "N/A";
    String humidity = widget.notificationData['Humidity'] ?? "N/A";
    String rainfall = widget.notificationData['Rainfall'] ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Alert"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
  child: SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // ✅ Disease Alert Message
        const Text(
          "Your field is at risk of",
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),

        // ✅ Disease Name
        Text(
          diseaseName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),

        // ✅ Disease Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            getDiseaseImagePath(diseaseName),
            width: MediaQuery.of(context).size.width * 0.9,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 20),

        // ✅ Recommendation Container
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recommendation",
                style: TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              recommendation1 != null && recommendation2 != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recommendation1!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(recommendation2!, style: const TextStyle(fontSize: 14)),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ],
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
