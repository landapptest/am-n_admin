// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'views/user_list_view.dart';

// 1) 백그라운드 메시지 핸들러 (앱이 종료/백그라운드 상태에서 FCM 받을 때)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 꼭 Firebase.initializeApp 필요 (백그라운드 isolate)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[BG Handler] 메시지 ID: ${message.messageId}');
  // 여기서 로그 남기거나 DB 업데이트 가능 (관리자 앱이니까)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) 안드로이드 13+ 및 iOS 알림 권한 요청
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('[FCM] 권한: ${settings.authorizationStatus}');

  // 3) 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4) 디버그용: 현재 관리자 앱의 FCM 토큰 확인
  final token = await FirebaseMessaging.instance.getToken();
  print('[FCM] 관리자 앱 Token: $token');
  // 필요시 DB(adminTokens) 등에 저장 → Cloud Functions에서 이 토큰에 푸시

  // 5) 앱이 포그라운드 상태에서 알림 수신
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[onMessage] 포그라운드 알림 수신');
    if (message.notification != null) {
      print('알림제목: ${message.notification!.title}');
      print('알림내용: ${message.notification!.body}');
    }
    // 여기에 local_notification 패키지로 시스템 알림 배너 띄우는 로직 추가 가능
  });

  // 6) 사용자가 알림 클릭 후 앱을 열었을 때
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('[onMessageOpenedApp] 알림 탭하여 앱 열림');
    // 예: 특정 화면으로 이동할 수 있음
  });

  // 7) runApp
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin App',
      debugShowCheckedModeBanner: false,
      home: const UserListView(), // 첫 화면: 미승인 유저 목록
    );
  }
}
