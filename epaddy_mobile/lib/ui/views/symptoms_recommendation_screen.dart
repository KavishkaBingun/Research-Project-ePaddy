// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math';

// class SymptomsRecommendationScreen extends StatefulWidget {
//   final String imagePath;
//   final String disease;

//   const SymptomsRecommendationScreen({
//     Key? key,
//     required this.imagePath,
//     required this.disease,
//   }) : super(key: key);

//   @override
//   _SymptomsRecommendationScreenState createState() =>
//       _SymptomsRecommendationScreenState();
// }

// class _SymptomsRecommendationScreenState
//     extends State<SymptomsRecommendationScreen> {
//   String? symptom1;
//   String? symptom2;

//   @override
//   void initState() {
//     super.initState();
//     fetchRandomSymptoms();
//   }

//   // ✅ Function to fetch random symptoms from Firestore
//   Future<void> fetchRandomSymptoms() async {
//     try {
//       DocumentSnapshot<Map<String, dynamic>> docSnapshot =
//           await FirebaseFirestore.instance
//               .collection('leafResultPrediction')
//               .doc(widget.disease.toLowerCase())
//               .get();

//       if (docSnapshot.exists) {
//         Map<String, dynamic>? data = docSnapshot.data();

//         if (data != null && data.isNotEmpty) {
//           List<String> values =
//               data.values.map((value) => value.toString()).toList();

//           if (values.length >= 2) {
//             values.shuffle(Random()); // Randomize the list
//             setState(() {
//               symptom1 = values[0];
//               symptom2 = values[1];
//             });
//           } else {
//             // If less than 2 values exist, use what is available
//             setState(() {
//               symptom1 = values.isNotEmpty ? values[0] : "No data available";
//               symptom2 = values.length > 1 ? values[1] : "No data available";
//             });
//           }
//         }
//       }
//     } catch (e) {
//       print("❌ Error fetching symptoms: $e");
//       setState(() {
//         symptom1 = "Error loading data";
//         symptom2 = "Error loading data";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Symptoms & Recommendations"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.file(
//                       File(widget.imagePath),
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       widget.disease, // ✅ Dynamic Disease Name
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Symptoms Section
//             const Text(
//               "Recommendations",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 5),
//             symptom1 != null && symptom2 != null
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(symptom1!, style: const TextStyle(fontSize: 14)),
//                       const SizedBox(height: 10),
//                       Text(symptom2!, style: const TextStyle(fontSize: 14)),
//                     ],
//                   )
//                 : const Center(
//                     child:
//                         CircularProgressIndicator()), // Show loading spinner while fetching data
//             const SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SymptomsRecommendationScreen extends StatefulWidget {
  final String imagePath;
  final String disease;

  const SymptomsRecommendationScreen({
    Key? key,
    required this.imagePath,
    required this.disease,
  }) : super(key: key);

  @override
  _SymptomsRecommendationScreenState createState() =>
      _SymptomsRecommendationScreenState();
}

class _SymptomsRecommendationScreenState
    extends State<SymptomsRecommendationScreen> {
  List<String> symptoms = []; // ✅ Store all symptoms in a list
  bool isLoading = true; // ✅ Show loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    fetchSymptoms();
  }

  // ✅ Function to fetch symptoms from Firestore
  Future<void> fetchSymptoms() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('leafResultPrediction')
              .doc(widget.disease.toLowerCase())
              .get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        if (data != null && data.isNotEmpty) {
          List<String> values =
              data.values.map((value) => value.toString()).toList();
          values.shuffle(Random()); // Randomize order

          setState(() {
            symptoms = values;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          symptoms = ["No data available"];
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching symptoms: $e");
      setState(() {
        symptoms = ["Error loading data"];
        isLoading = false;
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
            Container(
              padding: const EdgeInsets.all(10),
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
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.disease, // ✅ Dynamic Disease Name
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

            // Symptoms Section
            const Text(
              "Recommendations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // ✅ Show loading spinner while fetching data
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : symptoms.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: symptoms.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "• ${symptoms[index]}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ),
                      )
                    : const Text("No data available"),
          ],
        ),
      ),
    );
  }
}
