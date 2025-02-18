// lib/views/user_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/providers/admin_provider.dart';
import 'package:admin_amin/view_models/admin_view_model.dart';
import 'package:admin_amin/models/user_model.dart';
import 'user_detail_view.dart';

class UserListView extends ConsumerStatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<UserListView> {
  @override
  void initState() {
    super.initState();
    // 앱 실행 시점에 미승인 유저 가져옴
    Future.microtask(() {
      ref.read(adminViewModelProvider.notifier).fetchUnapprovedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminViewModelProvider);
    final adminViewModel = ref.read(adminViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("관리자용 - 미승인 학생증 목록"),
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminState.errorMessage.isNotEmpty
          ? Center(child: Text("에러: ${adminState.errorMessage}"))
          : ListView.builder(
        itemCount: adminState.unapprovedList.length,
        itemBuilder: (context, index) {
          final user = adminState.unapprovedList[index];
          return ListTile(
            leading: (user.studentCardUrl.isEmpty)
                ? const Icon(Icons.image_not_supported)
                : Image.network(user.studentCardUrl, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(user.userName),
            subtitle: Text("UID: ${user.uid}"),
            onTap: () {
              // 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailView(user: user),
                ),
              ).then((_) {
                // 상세 화면에서 승인/거부 후 돌아오면 목록 갱신
                adminViewModel.fetchUnapprovedUsers();
              });
            },
          );
        },
      ),
    );
  }
}
