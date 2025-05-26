// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math';

// class PredictionScreen extends StatefulWidget {
//   final String cropName;
//   final int nitrogen;
//   final int phosphorus;
//   final int potassium;

//   const PredictionScreen({
//     super.key,
//     required this.cropName,
//     required this.nitrogen,
//     required this.phosphorus,
//     required this.potassium,
//   });

//   @override
//   State<PredictionScreen> createState() => _PredictionScreenState();
// }

// class _PredictionScreenState extends State<PredictionScreen> {
//   List<String> recommendations = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRecommendations();
//   }

//   // ✅ Fetch random recommendations based on nitrogen value
//   Future<void> _fetchRecommendations() async {
//     String docId = widget.nitrogen >= 50 ? "over50" : "under50";

//     try {
//       DocumentSnapshot<Map<String, dynamic>> docSnapshot =
//           await FirebaseFirestore.instance.collection('npkRecommendation').doc(docId).get();

//       if (docSnapshot.exists) {
//         Map<String, dynamic>? data = docSnapshot.data();
//         if (data != null && data.isNotEmpty) {
//           List<String> values = data.values.map((value) => value.toString()).toList();

//           if (values.length >= 2) {
//             values.shuffle(Random()); // Shuffle values randomly
//             setState(() {
//               recommendations = [values[0], values[1]];
//             });
//           } else {
//             setState(() {
//               recommendations = values.isNotEmpty ? [values[0]] : ["No recommendations available"];
//             });
//           }
//         }
//       } else {
//         setState(() {
//           recommendations = ["No recommendations found"];
//         });
//       }
//     } catch (e) {
//       print("❌ Error fetching recommendations: $e");
//       setState(() {
//         recommendations = ["Error loading recommendations"];
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Prediction & Recommendations"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ Crop Prediction Card
//             SizedBox(
//               width: double.infinity, // Makes the container full width
//               child: Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Crop Name : ${widget.cropName}",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text("N : ${widget.nitrogen}",
//                         style: const TextStyle(color: Colors.white, fontSize: 16)),
//                     Text("P : ${widget.phosphorus}",
//                         style: const TextStyle(color: Colors.white, fontSize: 16)),
//                     Text("K : ${widget.potassium}",
//                         style: const TextStyle(color: Colors.white, fontSize: 16)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ✅ Recommendations Section
//             const Text(
//               "Recommendations",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),

//             // ✅ Show Recommendations
//             isLoading
//                 ? const Center(child: CircularProgressIndicator()) // Show loading
//                 : recommendations.isNotEmpty
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: recommendations.map((rec) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 5),
//                             child: Text("• $rec",
//                                 style: const TextStyle(fontSize: 16)),
//                           );
//                         }).toList(),
//                       )
//                     : const Text("No recommendations available."),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionScreen extends StatefulWidget {
  final String cropName;
  final int nitrogen;
  final int phosphorus;
  final int potassium;

  const PredictionScreen({
    super.key,
    required this.cropName,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  List<String> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    String docId = widget.nitrogen >= 50
        ? "over50"
        : "under50"; // ✅ Ensure "under50" is fetched correctly

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('npkRecommendation')
              .doc(docId)
              .get();

      if (!docSnapshot.exists) {
        print("❌ Document not found: $docId");
        setState(() {
          recommendations = ["No recommendations found"];
        });
        return;
      }

      Map<String, dynamic>? data = docSnapshot.data();
      print("📌 Retrieved data for $docId: $data");

      if (data == null || data.isEmpty) {
        setState(() {
          recommendations = ["No recommendations available"];
        });
        return;
      }

      List<String> values = data.values
          .map((value) => value.toString()) // ✅ Ensure all values are strings
          .toList();

      print("✅ Processed recommendations: $values");

      setState(() {
        recommendations = values;
      });
    } catch (e) {
      print("❌ Error fetching recommendations: $e");
      setState(() {
        recommendations = ["Error loading recommendations"];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction & Recommendations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Crop Prediction Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crop Name: ${widget.cropName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("N: ${widget.nitrogen}",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  Text("P: ${widget.phosphorus}",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  Text("K: ${widget.potassium}",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Recommendations Section
            const Text(
              "Recommendations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ Show recommendations dynamically using ListView.builder
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recommendations.isNotEmpty
                      ? ListView.builder(
                          itemCount: recommendations.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                "• ${recommendations[index]}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No recommendations available.")),
            ),
          ],
        ),
      ),
    );
  }
}
