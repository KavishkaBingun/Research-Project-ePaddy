import 'package:epaddy_mobile/ui/views/recommendation_screen_phase.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PhasePredictionScreen extends StatelessWidget {
  final String imagePath;
  final String predictedPhase;

  const PhasePredictionScreen({Key? key, required this.imagePath, required this.predictedPhase}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phase Prediction"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Description
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath),
                    width: 362,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phase Summary Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Phase Summary",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Input Fields (Dynamic Text)
            Column(
              children: [
                 _buildInputRow("Predicted Phase", predictedPhase),
                 const SizedBox(height: 10),
                 _buildInputRowButton(
                  "Recommendations",
                  trailingWidget: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationForPhaseScreen(
                              imagePath: imagePath,
                              disease: predictedPhase,),
                        ),
                      );
                    },
                    child: const Text("Click Here"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton("Capture Again", Colors.green, () {
                  Navigator.pop(context);
                }),
                _buildButton("Done", Colors.green, () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom Widget for Input Row
  Widget _buildInputRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Container(
          width: 150,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRowButton(String label, {String? value, Widget? trailingWidget}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailingWidget ??
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
    ],
  );
}


  // Custom Button Widget
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}
