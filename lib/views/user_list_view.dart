import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/providers/admin_provider.dart';
import 'user_detail_view.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserListView extends ConsumerStatefulWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  ConsumerState<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<UserListView> {
  @override
  void initState() {
    super.initState();
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
                    width: 50, height: 50,
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
                  width: 50, height: 50,
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
