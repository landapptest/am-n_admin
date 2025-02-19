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

  Future<void> fetchUnapprovedUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final snapshot = await FirebaseDatabase.instance.ref('users').get();

      if (!snapshot.exists) {
        state = state.copyWith(isLoading: false, unapprovedList: []);
        return;
      }

      final rawMap = Map<String, dynamic>.from(snapshot.value as Map);
      final result = <UserModel>[];

      rawMap.forEach((uid, data) {
        final userMap = Map<String, dynamic>.from(data as Map);
        final user = UserModel.fromJson(uid, userMap);
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

  Future<void> approveUser(String uid) async {
    try {
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({'isApproved': true});
      await fetchUnapprovedUsers();
    } catch (e) {
      state = state.copyWith(errorMessage: '승인 에러: $e');
    }
  }

  Future<void> rejectUser(String uid, String reason) async {
    try {
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({
        'isApproved': false,
        'rejectedReason': reason.isEmpty ? '관리자 거부' : reason,
      });
      await fetchUnapprovedUsers();
    } catch (e) {
      state = state.copyWith(errorMessage: '거부 에러: $e');
    }
  }
}
