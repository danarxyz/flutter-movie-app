import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
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
}
