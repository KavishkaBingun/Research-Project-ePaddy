import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart'; // For date formatting

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Disease Identification"),
              Tab(text: "Soil Status"),
              Tab(text: "Paddy Phase"),
              Tab(text: "Pest Identification"),
              Tab(text: "Weather Alert"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HistoryTab(
                collectionName: "leafDisease",
                field: "disease",
                prefix: "Disease: "),
            HistoryTab(
                collectionName: "cropRecommend",
                field: "predictedCrop",
                prefix: "Recommend Crop: "),
            HistoryTab(
                collectionName: "paddyPhase",
                field: "predictedPhase",
                prefix: "Phase: "),
            HistoryTab(
                collectionName: "pestPredict",
                field: "pest",
                prefix: "Pest: "),
            HistoryTab(
                collectionName: "weather_predictions",
                field: "prediction",
                prefix: "Disease: "),
          ],
        ),
      ),
    );
  }
}

class HistoryTab extends StatelessWidget {
  final String collectionName;
  final String field;
  final String prefix;

  const HistoryTab(
      {super.key,
      required this.collectionName,
      required this.field,
      required this.prefix});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy("timestamp", descending: true)
          .limit(5) // 🔹 Pagination: Load only latest 5 records
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No history available"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // ✅ Convert timestamp to readable date format
            String formattedTime = "Unknown Time";
            if (data.containsKey("timestamp")) {
              Timestamp? timestamp = data["timestamp"];
              if (timestamp != null) {
                formattedTime = DateFormat('yyyy-MM-dd HH:mm')
                    .format(timestamp.toDate());
              }
            }

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: _buildImage(data),
                title: Text(
                  "$prefix${data[field] ?? "No Data"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("📅 $formattedTime"), // ✅ Display timestamp
                trailing: data.containsKey("imageBase64")
                    ? IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        onPressed: () => _showImageDialog(context, data),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImage(Map<String, dynamic> data) {
    if (data.containsKey("imageBase64")) {
      Uint8List bytes = base64Decode(data["imageBase64"]);
      return Image.memory(bytes, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.image_not_supported, size: 50);
    }
  }

  void _showImageDialog(BuildContext context, Map<String, dynamic> data) {
    if (data.containsKey("imageBase64")) {
      Uint8List bytes = base64Decode(data["imageBase64"]);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Image Preview"),
          content: Image.memory(bytes),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }
}
