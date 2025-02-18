// lib/models/user_model.dart

class UserModel {
  final String uid;

  // 예시: 기존
  final String userName;
  final String studentCardUrl;
  final bool isApproved;

  // 추가 정보
  final String gender;
  final String ageGroup;
  final String purpose;
  final String introduce;

  UserModel({
    required this.uid,
    required this.userName,
    required this.studentCardUrl,
    required this.isApproved,
    required this.gender,
    required this.ageGroup,
    required this.purpose,
    required this.introduce,
  });

  factory UserModel.fromJson(String uid, Map<String, dynamic> json) {
    return UserModel(
      uid: uid,
      userName: json['userName'] as String? ?? '',
      studentCardUrl: json['studentCardUrl'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? false,

      gender: json['gender'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      introduce: json['introduce'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'studentCardUrl': studentCardUrl,
      'isApproved': isApproved,
      'gender': gender,
      'ageGroup': ageGroup,
      'purpose': purpose,
      'introduce': introduce,
    };
  }
}
