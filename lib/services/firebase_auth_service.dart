import 'package:firebase_auth/firebase_auth.dart';

import '../models/vault_user.dart';

class AuthResult {
  const AuthResult._({required this.success, this.errorKey, this.user});

  final bool success;
  final String? errorKey;
  final VaultUser? user;

  factory AuthResult.success(VaultUser user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String errorKey) {
    return AuthResult._(success: false, errorKey: errorKey);
  }
}

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<VaultUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return _toVaultUser(user);
    });
  }

  Future<VaultUser?> loadCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return _toVaultUser(user);
  }

  Future<AuthResult> signUp({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final sanitizedName = displayName.trim();
    final sanitizedEmail = email.trim().toLowerCase();
    if (sanitizedName.isEmpty || sanitizedEmail.isEmpty || password.isEmpty) {
      return AuthResult.failure('errors.emptyFields');
    }
    if (password != confirmPassword) {
      return AuthResult.failure('errors.passwordMismatch');
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('errors.invalidCredentials');
      }

      await user.updateDisplayName(sanitizedName);
      await user.reload();

      final refreshedUser = _firebaseAuth.currentUser;
      if (refreshedUser == null) {
        return AuthResult.failure('errors.invalidCredentials');
      }

      return AuthResult.success(_toVaultUser(refreshedUser));
    } on FirebaseAuthException catch (error) {
      return AuthResult.failure(_mapFirebaseError(error));
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();
    if (sanitizedEmail.isEmpty || password.isEmpty) {
      return AuthResult.failure('errors.emptyFields');
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('errors.invalidCredentials');
      }

      return AuthResult.success(_toVaultUser(user));
    } on FirebaseAuthException catch (error) {
      return AuthResult.failure(_mapFirebaseError(error));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> clearAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    await user.delete();
  }

  VaultUser _toVaultUser(User user) {
    return VaultUser(
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (user.email?.split('@').first ?? 'User'),
      email: user.email ?? '',
    );
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'errors.accountExists';
      case 'user-not-found':
        return 'errors.accountMissing';
      case 'invalid-credential':
      case 'wrong-password':
        return 'errors.invalidCredentials';
      case 'weak-password':
        return 'errors.weakPassword';
      case 'requires-recent-login':
        return 'errors.reauthRequired';
      default:
        return 'errors.invalidCredentials';
    }
  }
}