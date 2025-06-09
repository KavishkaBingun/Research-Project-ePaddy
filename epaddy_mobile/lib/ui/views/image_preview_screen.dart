import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/service/api_service.dart';
import 'phase_prediction_screen.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath})
      : super(key: key);

  /// ✅ Convert Image File to Base64 String
  Future<String> _convertImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  /// ✅ Process Image: Upload to API, Convert to Base64, Save to Firestore
  Future<void> _processImage(BuildContext context) async {
    File imageFile = File(imagePath);
    ApiService apiService = ApiService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // ✅ Upload image to API
    Map<String, dynamic>? result =
        await apiService.uploadPaddyPhaseImage(imageFile);

    Navigator.pop(context); // Close loading dialog

    if (result != null) {
      String phase = result["category"];

      // ✅ Convert image to Base64
      String base64Image = await _convertImageToBase64(imageFile);

      // ✅ Save Base64 Image to Firestore
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('paddyPhase').add({
        "userId": user?.uid,
        'imageBase64': base64Image, // 🔹 Save Base64 instead of file path
        'predictedPhase': phase,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Navigate to Phase Prediction Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhasePredictionScreen(
            imagePath: imagePath,
            predictedPhase: phase,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error processing image. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.cover),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => _processImage(context),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("Confirm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
