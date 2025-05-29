import 'package:epaddy_mobile/ui/views/symptoms_recommendation_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DiseaseIdentificationOtherScreen extends StatelessWidget {
  final String imagePath;

  const DiseaseIdentificationOtherScreen(
      {Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disease Identification"),
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
            // Image and Description
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath),
                    width: 360,
                    height: 360,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Disease Summary",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This plant shows signs of disease, but it does not match Bacterial Leaf Blight, Brown Spot, or Rice Blast.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Recommendation",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Meet an agricultural expert for further information about this disease.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
           
            const SizedBox(height: 25),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Capture Again"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
