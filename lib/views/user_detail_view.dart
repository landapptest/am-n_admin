// lib/views/user_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/models/user_model.dart';
import 'package:admin_amin/providers/admin_provider.dart';

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
            // 학생증 이미지
            if (user.studentCardUrl.isNotEmpty)
              Image.network(
                user.studentCardUrl,
                fit: BoxFit.contain,
                height: 300,
                errorBuilder: (ctx, error, stack) => const Text("이미지 로드 실패"),
              )
            else
              const Text("학생증 이미지가 없습니다."),

            const SizedBox(height: 20),

            // 기본 정보
            Text("이름: ${user.userName}", style: const TextStyle(fontSize: 18)),
            Text("UID: ${user.uid}"),
            Text("승인 여부: ${user.isApproved}"),

            const SizedBox(height: 20),
            // 추가 정보 표시
            Text("성별: ${user.gender}"),
            Text("나이대: ${user.ageGroup}"),
            Text("목적: ${user.purpose}"),
            const SizedBox(height: 10),
            Text("자기소개:\n${user.introduce}"),

            const Spacer(),

            // 승인 / 거부 버튼
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
                    await adminViewModel.rejectUser(user.uid);
                    Navigator.pop(context);
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
