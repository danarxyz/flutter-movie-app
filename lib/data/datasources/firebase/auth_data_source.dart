import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile({String? displayName, String? photoUrl});
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
  Future<void> sendPasswordResetEmail(String email);
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth firebaseAuth;

  AuthDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    if (user != null) {
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        profileImageUrl: user.photoURL,
      );
    } else {
      throw Exception('Sign in failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String name) async {
    final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    if (user != null) {
      await user.updateDisplayName(name);
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: name,
        profileImageUrl: user.photoURL,
      );
    } else {
      throw Exception('Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        profileImageUrl: user.photoURL,
      );
    }
    return null;
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) throw Exception('Not logged in');
    
    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount(String password) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) throw Exception('Not logged in');
    
    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

