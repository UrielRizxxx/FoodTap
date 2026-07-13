import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  Future<void> createUser(UserModel user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final document = await users.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromMap(document.data()!);
  }

  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await users.doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }
}