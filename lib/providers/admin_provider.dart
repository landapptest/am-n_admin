// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_amin/view_models/admin_view_model.dart';

final adminViewModelProvider =
StateNotifierProvider<AdminViewModel, AdminState>((ref) {
  return AdminViewModel();
});
