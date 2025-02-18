// lib/view_models/admin_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AdminState {
  final bool isLoading;
  final String errorMessage;
  final List<UserModel> unapprovedList;

  AdminState({
    this.isLoading = false,
    this.errorMessage = '',
    this.unapprovedList = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? unapprovedList,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      unapprovedList: unapprovedList ?? this.unapprovedList,
    );
  }
}

class AdminViewModel extends StateNotifier<AdminState> {
  AdminViewModel() : super(AdminState());

  /// 미승인 사용자 목록을 단발성 fetch (Future)
  Future<void> fetchUnapprovedUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final snapshot = await FirebaseDatabase.instance.ref('users').get();

      if (!snapshot.exists) {
        // no users
        state = state.copyWith(isLoading: false, unapprovedList: []);
        return;
      }

      final rawMap = Map<String, dynamic>.from(snapshot.value as Map);
      final result = <UserModel>[];

      rawMap.forEach((uid, data) {
        final userMap = Map<String, dynamic>.from(data as Map);
        // parse
        final user = UserModel.fromJson(uid, userMap);
        // isApproved == false 인 경우만 목록에
        if (user.isApproved == false) {
          result.add(user);
        }
      });

      state = state.copyWith(
        isLoading: false,
        unapprovedList: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// 승인 처리
  Future<void> approveUser(String uid) async {
    try {
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({'isApproved': true});

      // 승인 후 목록 재갱신
      await fetchUnapprovedUsers();
    } catch (e) {
      state = state.copyWith(errorMessage: '승인 에러: $e');
    }
  }

  /// 거부 처리 (예: isApproved 필드를 false로 유지하거나, 별도 필드 rejectedReason?)
  Future<void> rejectUser(String uid) async {
    try {
      // 여기선 단순히 isApproved: false 유지
      // or set {'isApproved': false, 'rejectedReason': ...}
      // 만약 이미 false라면 그대로이므로, 굳이 update 안 해도 됨
      // But for example:
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({'isApproved': false, 'rejectedReason': 'Admin Rejected'});

      await fetchUnapprovedUsers();
    } catch (e) {
      state = state.copyWith(errorMessage: '거부 에러: $e');
    }
  }
}
