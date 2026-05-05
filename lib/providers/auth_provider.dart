import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthService? authService, DatabaseService? databaseService})
      : _authService = authService ?? AuthService(),
        _databaseService = databaseService ?? DatabaseService();

  final AuthService _authService;
  final DatabaseService _databaseService;

  User? get firebaseUser => _authService.getCurrentUser();

  /// Backwards-compatible alias used by older screens.
  User? get currentUser => firebaseUser;

  Stream<User?> authStateChanges() => _authService.user;

  /// Signs the user up. The profile document is written by [AuthService] so
  /// there is exactly one Firestore write.
  Future<void> signUp(UserModel user, String password) async {
    await _authService.signUp(user, password);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  /// Single source of truth for the admin check. Falls back to `false` if the
  /// user document is unavailable (e.g. signed out, network error).
  Future<bool> isAdmin() async {
    final user = firebaseUser;
    if (user == null) return false;
    return _databaseService.isUserAdmin(user.uid);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = firebaseUser;
    if (user == null) return null;
    return _databaseService.getUserById(user.uid);
  }

  /// Kept for source compatibility; new code should use [getCurrentUserProfile].
  Future<UserModel?> getCurrentUser() => getCurrentUserProfile();

  Future<void> resetPassword(String email) =>
      _authService.resetPassword(email);

  Future<void> updateUserProfile(UserModel user) async {
    await _databaseService.updateUserProfile(user);
    notifyListeners();
  }
}
