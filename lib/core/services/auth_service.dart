import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await _auth.signOut();
        return;
      }

      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    debugPrint('A - Creando usuario');

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    debugPrint('B - Usuario creado');

    final user = credential.user!;

    await user.updateDisplayName(name);

    debugPrint('C - Nombre actualizado');

    await user.sendEmailVerification();

    debugPrint('D - Correo enviado');

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email.trim(),
      role: 'buyer',
      isSeller: false,
      isAdmin: false,
      emailVerified: false,
      createdAt: DateTime.now(),
      photoUrl: null,
    );

    debugPrint('E - Guardando usuario en Firestore');

    await FirestoreService.instance.createUser(userModel);

    debugPrint('F - Usuario guardado');

    return userModel;
  }

  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}