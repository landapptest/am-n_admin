import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(FirebaseAuth.instance.currentUser != null);

  void setLoggedIn(bool value) {
    state = value;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
