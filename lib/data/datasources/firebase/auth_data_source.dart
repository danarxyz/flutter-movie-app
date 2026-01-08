import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
    String email, 
    String password, 
    String name,
    String username,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile({String? displayName, String? photoUrl});
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> isUsernameAvailable(String username);
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseDatabase firebaseDatabase;

  AuthDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseDatabase,
  });

  DatabaseReference get _usersRef => firebaseDatabase.ref('users');
  DatabaseReference get _usernamesRef => firebaseDatabase.ref('usernames');

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    if (user != null) {
      // Fetch user data from Realtime DB
      final snapshot = await _usersRef.child(user.uid).get();
      
      if (snapshot.exists && snapshot.value != null) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        userData['id'] = user.uid;
        return UserModel.fromMap(userData);
      }
      
      // Fallback jika belum ada di database (user lama)
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        username: user.email!.split('@')[0],
        profileImageUrl: user.photoURL,
      );
    } else {
      throw Exception('Sign in failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email, 
    String password, 
    String name,
    String username,
  ) async {
    // 1. Check username uniqueness
    final isAvailable = await isUsernameAvailable(username);
    if (!isAvailable) {
      throw Exception('Username already taken');
    }

    // 2. Create auth user
    final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    
    if (user != null) {
      await user.updateDisplayName(name);
      
      // 3. Create user profile in Realtime DB
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        username: username,
        profileImageUrl: user.photoURL,
        role: 'user',
        createdAt: DateTime.now(),
      );
      
      // Save to users/{uid}
      await _usersRef.child(user.uid).set(userModel.toFirebaseMap());
      
      // 4. Reserve username (untuk quick lookup)
      await _usernamesRef.child(username.toLowerCase()).set(user.uid);
      
      return userModel;
    } else {
      throw Exception('Sign up failed');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final snapshot = await _usernamesRef.child(username.toLowerCase()).get();
    return !snapshot.exists;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      // Fetch from Realtime DB
      final snapshot = await _usersRef.child(user.uid).get();
      
      if (snapshot.exists && snapshot.value != null) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        userData['id'] = user.uid;
        return UserModel.fromMap(userData);
      }
      
      // Fallback
      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        username: user.email!.split('@')[0],
        profileImageUrl: user.photoURL,
      );
    }
    return null;
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw Exception('Not logged in');
    
    // Update both Auth and Database
    if (displayName != null) {
      await user.updateDisplayName(displayName);
      await _usersRef.child(user.uid).update({'name': displayName});
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
      await _usersRef.child(user.uid).update({'profileImageUrl': photoUrl});
    }
    await user.reload();
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = firebaseAuth.currentUser;
    if (user == null || user.email == null) throw Exception('Not logged in');
    
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
    
    // Get username before deletion
    final snapshot = await _usersRef.child(user.uid).get();
    String? username;
    if (snapshot.exists && snapshot.value != null) {
      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      username = userData['username'];
    }
    
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    
    // Delete from Realtime DB
    await _usersRef.child(user.uid).remove();
    if (username != null) {
      await _usernamesRef.child(username.toLowerCase()).remove();
    }
    
    // Delete auth account
    await user.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
