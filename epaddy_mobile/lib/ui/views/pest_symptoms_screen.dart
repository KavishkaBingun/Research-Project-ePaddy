import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PestSymptomsScreen extends StatefulWidget {
  final String imagePath;
  final String pestName;

  const PestSymptomsScreen({Key? key, required this.imagePath, required this.pestName})
      : super(key: key);

  @override
  _PestSymptomsScreenState createState() => _PestSymptomsScreenState();
}

class _PestSymptomsScreenState extends State<PestSymptomsScreen> {
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
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance.collection('pestResultRecomendation').doc(widget.pestName.toLowerCase()).get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptoms & Recommendations"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image and Pest Name
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.pestName, // ✅ Dynamic Pest Name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Recommendations Section
            const Text(
              "Recommendations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            recommendation1 != null && recommendation2 != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recommendation1!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(recommendation2!, style: const TextStyle(fontSize: 14)),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()), // Show loading spinner while fetching data
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
