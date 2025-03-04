import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_amin/views/user_list_view.dart';
import 'package:admin_amin/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/admin_token_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AdminLoginView extends ConsumerStatefulWidget {
  @override
  _AdminLoginViewState createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends ConsumerState<AdminLoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      ref.read(authProvider.notifier).setLoggedIn(true);

      // (A) 로그인 후에도 FCM 토큰 확인해서 로그 남기기
      String? newToken = await FirebaseMessaging.instance.getToken();
      print("[DEBUG] (로그인 직후) FCM 토큰: $newToken");

      // 관리자 로그인 성공 후, FCM 토큰을 데이터베이스에 저장
      await AdminTokenService.updateAdminToken();

      // Future.microtask()를 사용해 안전하게 화면 전환
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserListView()),
          );
        }
      });
    } catch (e) {
      print("❌ 로그인 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("관리자 로그인")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "이메일"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text("로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
