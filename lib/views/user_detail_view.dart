import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/models/user_model.dart';
import 'package:admin_amin/providers/admin_provider.dart';
import 'package:firebase_storage/firebase_storage.dart'; // 추가

class UserDetailView extends ConsumerWidget {
  final UserModel user;

  const UserDetailView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminViewModel = ref.read(adminViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("사용자 상세"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (user.studentCardUrl.isEmpty)
              const Text("학생증 이미지가 없습니다.")
            else
              FutureBuilder<String>(
                future: FirebaseStorage.instance
                    .ref(user.studentCardUrl)
                    .getDownloadURL(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("이미지 로드 오류: ${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return const Text("이미지 로드 실패");
                  }
                  final downloadUrl = snapshot.data!;
                  return Image.network(
                    downloadUrl,
                    fit: BoxFit.contain,
                    height: 300,
                    errorBuilder: (ctx, error, stack) =>
                    const Text("이미지 로드 실패"),
                  );
                },
              ),

            const SizedBox(height: 20),

            Text("이름: ${user.userName}", style: const TextStyle(fontSize: 18)),
            Text("UID: ${user.uid}"),
            Text("승인 여부: ${user.isApproved}"),

            const SizedBox(height: 20),
            Text("성별: ${user.gender}"),
            Text("나이대: ${user.ageGroup}"),
            Text("목적: ${user.purpose}"),
            const SizedBox(height: 10),
            Text("자기소개:\n${user.introduce}"),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await adminViewModel.approveUser(user.uid);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("승인"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        final TextEditingController reasonController =
                        TextEditingController();
                        return AlertDialog(
                          title: const Text("거부 사유 입력"),
                          content: TextField(
                            controller: reasonController,
                            decoration: const InputDecoration(
                              labelText: "사유를 입력하세요",
                            ),
                            maxLines: 2,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("취소"),
                            ),
                            TextButton(
                              onPressed: () {
                                final reason = reasonController.text.trim();
                                adminViewModel.rejectUser(user.uid, reason);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text("확인"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("거부"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
