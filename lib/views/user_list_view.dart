import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/providers/admin_provider.dart';
import 'user_detail_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class UserListView extends ConsumerStatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<UserListView> {
  List<String> _messages = []; // 알림 메시지 저장 리스트

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminViewModelProvider.notifier).fetchUnapprovedUsers();
    });
  }

  void _showGroupedNotification(String title, String body) {
    const String groupKey = 'test_group';
    const String channelId = 'test_channel_id';

    _messages.add(body); // 새 메시지 추가

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'Test Channel',
      channelDescription: '테스트용 알림 채널',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    final NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformDetails,
    );

    final AndroidNotificationDetails summaryAndroidDetails = AndroidNotificationDetails(
      channelId,
      'Test Channel',
      channelDescription: '테스트용 알림 채널',
      styleInformation: InboxStyleInformation(_messages),
      setAsGroupSummary: true,
      groupKey: groupKey,
    );

    final NotificationDetails summaryNotificationDetails =
    NotificationDetails(android: summaryAndroidDetails);

    flutterLocalNotificationsPlugin.show(
      0,
      '새로운 알림들',
      '${_messages.length}개의 알림이 있습니다.',
      summaryNotificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminViewModelProvider);
    final adminViewModel = ref.read(adminViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("관리자용 - 미승인 학생증 목록"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showGroupedNotification('테스트 알림', '이것은 새로운 알림입니다.'),
          ),
        ],
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminState.errorMessage.isNotEmpty
          ? Center(child: Text("에러: ${adminState.errorMessage}"))
          : ListView.builder(
        itemCount: adminState.unapprovedList.length,
        itemBuilder: (context, index) {
          final user = adminState.unapprovedList[index];
          Widget leadingWidget;
          if (user.studentCardUrl.isEmpty) {
            leadingWidget = const Icon(Icons.image_not_supported);
          } else {
            leadingWidget = FutureBuilder<String>(
              future: FirebaseStorage.instance
                  .ref(user.studentCardUrl)
                  .getDownloadURL(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error, color: Colors.red);
                } else if (!snapshot.hasData) {
                  return const Icon(Icons.broken_image_outlined);
                }
                final downloadUrl = snapshot.data!;
                return Image.network(
                  downloadUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) =>
                  const Icon(Icons.broken_image_outlined),
                );
              },
            );
          }

          return ListTile(
            leading: leadingWidget,
            title: Text(user.userName),
            subtitle: Text("UID: ${user.uid}"),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailView(user: user),
                ),
              );
              adminViewModel.fetchUnapprovedUsers();
            },
          );
        },
      ),
    );
  }
}
