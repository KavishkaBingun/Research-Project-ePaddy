import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:epaddy_mobile/core/config/api_constants.dart';

class ApiService {
  Future<Map<String, dynamic>> getCropRecommendation(int nitrogen, int phosphorus, int potassium) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cropRecommend),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "N": nitrogen,
          "P": phosphorus,
          "K": potassium,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch recommendation");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<Map<String, dynamic>?> uploadImageDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.leafDisease));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadPestImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.pestPredict));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadPaddyPhaseImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.paddyPhaseClassifier));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        return null;
      }
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }
}
