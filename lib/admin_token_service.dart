import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 관리자 기기의 FCM 토큰을 Firebase Realtime Database에 저장하는 서비스
class AdminTokenService {
  /// 현재 로그인한 사용자가 관리자인 경우, FCM 토큰을 "adminTokens" 경로에 업데이트합니다.
  static Future<void> updateAdminToken() async {
    try {
      // 1. 현재 로그인한 사용자 가져오기
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("[AdminTokenService] 사용자가 로그인되어 있지 않습니다.");
        return;
      }

      // 2. 관리자 계정인지 확인 (여기서는 admin@admin.com 으로 고정)
      if (user.email != "admin@admin.com") {
        print("[AdminTokenService] 로그인한 사용자가 관리자가 아닙니다.");
        return;
      }

      // 3. FCM 토큰 획득 (비동기 호출)
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        print("[AdminTokenService] FCM 토큰을 가져올 수 없습니다.");
        return;
      }

      // 4. Firebase Realtime Database의 "adminTokens" 경로에 토큰 저장
      // 예시로, 각 관리자 사용자의 uid를 key로 사용하여 저장합니다.
      DatabaseReference ref = FirebaseDatabase.instance.ref("adminTokens/${user.uid}");
      await ref.set(token);

      print("[AdminTokenService] 관리자 토큰이 성공적으로 저장되었습니다. 토큰: $token");
    } catch (e) {
      print("[AdminTokenService] 토큰 업데이트 중 오류 발생: $e");
    }
  }
}
