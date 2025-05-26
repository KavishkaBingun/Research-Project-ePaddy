import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save User to Firestore
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get User by ID
  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 🔹 Get Current User
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("❌ Error fetching user: $e");
    }
    return null;
  }

  // 🔹 Update User Profile (Full Name & NIC)
  Future<void> updateUserProfile(String fullName, String nic) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'nic': nic,
      });
    }
  }

  // 🔹 Change User Password
  Future<String?> updateUserPassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return "Password updated successfully!";
      }
    } catch (e) {
      return "❌ Error updating password: ${e.toString()}";
    }
    return null;
  }

// Function to get the latest soil data
Future<Map<String, dynamic>?> getLatestSoilData() async {
  final user = _auth.currentUser;
  print(user);

  if (user == null) return null; // User not logged in

  try {
    DocumentSnapshot latestDoc = await _db
        .collection('users')
        .doc(user.uid)
        .collection('soil_data')
        .doc('latest')
        .get();

    if (latestDoc.exists) {
      return latestDoc.data() as Map<String, dynamic>;
    } else {
      print("No latest soil data found.");
    }
  } catch (e) {
    print("Error fetching soil data: $e");
  }

  return null;
}


  // 🔹 Function to get latest **Water Level Data**
  Future<Map<String, dynamic>?> getLatestWaterLevelData() async {
    final user = _auth.currentUser;
    if (user == null) return null; // User not logged in

    try {
    DocumentSnapshot latestDoc = await _db
        .collection('users')
        .doc(user.uid)
        .collection('Waterlevel_data')
        .doc('latest')
        .get();

    if (latestDoc.exists) {
      return latestDoc.data() as Map<String, dynamic>;
    } else {
      print("No latest soil data found.");
    }
  } catch (e) {
    print("Error fetching soil data: $e");
  }
    return null;
  }
}
