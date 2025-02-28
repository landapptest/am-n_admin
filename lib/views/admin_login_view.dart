import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin_amin/views/user_list_view.dart';
import 'package:admin_amin/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      // ✅ 로그인 후 ID 토큰 가져오기
      String? idToken = await userCredential.user?.getIdToken(true);
      print("🔑 관리자 ID 토큰: $idToken");

      // ✅ Future.microtask() 사용하여 안전하게 화면 전환
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
