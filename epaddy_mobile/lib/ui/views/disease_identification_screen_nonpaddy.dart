import 'package:epaddy_mobile/ui/views/symptoms_recommendation_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DiseaseIdentificationNonPaddyScreen extends StatelessWidget {
  final String imagePath;

  const DiseaseIdentificationNonPaddyScreen(
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
                    "This is not a paddy plant",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please upload an image of a paddy plant for accurate disease identification.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Paddy plant looks like below",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'assets/images/rice1.jpeg', // replace with your image path
                          fit: BoxFit.cover,
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Image.asset(
                          'assets/images/rice2.jpeg', // replace with your image path
                          fit: BoxFit.cover,
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Image.asset(
                          'assets/images/rice3.jpeg', // replace with your image path
                          fit: BoxFit.cover,
                          height: 100,
                        ),
                      ),
                    ],
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
