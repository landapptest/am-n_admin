import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static Future<void> sendAdminRequest() async {
    String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    final response = await http.post(
      Uri.parse('https://onusercreate-phadvjxyzq-as.a.run.app/'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"message": "관리자 요청 테스트"}),
    );

    if (response.statusCode == 200) {
      print("✅ 관리자 요청 성공!");
    } else {
      print("❌ 관리자 요청 실패: ${response.body}");
    }
  }
}
