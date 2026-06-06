import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mhdcooperation/data/models/user_model.dart';
import 'package:mhdcooperation/data/services/push_notification_service.dart';
import 'package:mhdcooperation/data/services/session_service.dart';

class AuthService extends GetxService {
  late final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _session = Get.find<SessionService>();

  Future<AuthService> init() async {
    _auth = FirebaseAuth.instance;
    await _refreshCurrentUserFromBackend();
    return this;
  }

  Future<void> _refreshCurrentUserFromBackend() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || !_session.isAuthenticated.value) {
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!userDoc.exists) return;

      final data = userDoc.data();
      if (data == null) return;

      final backendUser = _userFromFirestore(firebaseUser, data);
      await _session.setCurrentUser(backendUser);
    } catch (e, stackTrace) {
      debugPrint('Failed to refresh current user from backend: $e');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? city,
  }) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credentials.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Impossible de créer le compte.',
        );
      }

      await user.updateDisplayName(name);
      final token = await user.getIdToken(true);
      if (token == null) {
        throw Exception('Impossible de récupérer le token Firebase');
      }
      await _session.saveTokens(accessToken: token);

      final newUser = UserModel(
        id: user.uid,
        name: name,
        phoneNumber: '',
        pictureUrl: "",
        role: 'USER',
        email: user.email!,
        city: city,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final Map<String, dynamic> userData = {
        'id': newUser.id,
        'name': newUser.name,
        'phone_number': newUser.phoneNumber,
        'role': newUser.role,
        'email': newUser.email,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (newUser.pictureUrl != null) {
        userData['picture_url'] = newUser.pictureUrl;
      }

      if (newUser.city != null) {
        userData['city'] = newUser.city;
      }

      try {
        await _firestore.collection('users').doc(user.uid).set(userData);
      } catch (e, stackTrace) {
        debugPrint('Firestore signUp error for user ${user.uid}: $e');
        debugPrint(stackTrace.toString());
        rethrow;
      }

      await _session.setCurrentUser(newUser);
      _savePushTokenAfterLogin(newUser.city);
    } catch (e, stackTrace) {
      debugPrint('signUp failed for email $email: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Aucun utilisateur trouvé.',
      );
    }

    final token = await user.getIdToken(true);
    await _session.saveTokens(accessToken: token!);

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Utilisateur non trouvé dans Firestore.',
      );
    }

    final data = userDoc.data()!;
    final currentUser = _userFromFirestore(user, data);

    await _session.setCurrentUser(currentUser);
    _savePushTokenAfterLogin(currentUser.city);
  }

  void _savePushTokenAfterLogin(String? city) {
    Future.microtask(() async {
      try {
        final push = Get.find<PushNotificationService>();
        await push.saveTokenForCurrentUser();
        await push.subscribeToTopics(city);
      } catch (e) {
        debugPrint('[AuthService] Push token save error: $e');
      }
    });
  }

  UserModel _userFromFirestore(User user, Map<String, dynamic> data) {
    return UserModel(
      id: user.uid,
      name: data['name'] ?? user.displayName ?? 'Utilisateur',
      phoneNumber: data['phone_number'] ?? user.phoneNumber ?? '',
      pictureUrl: data['picture_url'] ?? user.photoURL,
      role: data['role'] ?? 'USER',
      email: data['email'] ?? user.email,
      city: data['city'],
      createdAt: _parseDateTime(data['created_at']),
      updatedAt: _parseDateTime(data['updated_at']),
    );
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? city,
    String? pictureUrl,
  }) async {
    final currentUser = _session.currentUser.value;
    if (currentUser == null) {
      throw Exception('Aucun utilisateur connecté');
    }

    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw Exception('Utilisateur Firebase non disponible');
    }

    final updatedName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : currentUser.name;
    final updatedEmail = email?.trim().isNotEmpty == true
        ? email!.trim()
        : currentUser.email;
    final updatedPhone = phoneNumber?.trim() ?? '';
    final updatedCity = city?.trim() ?? '';

    final updatedData = <String, dynamic>{
      'name': updatedName,
      'email': updatedEmail,
      'phone_number': updatedPhone,
      'city': updatedCity,
      'updated_at': FieldValue.serverTimestamp(),
    };

    String? finalPictureUrl = currentUser.pictureUrl;
    if (pictureUrl != null) {
      if (pictureUrl.startsWith('http')) {
        finalPictureUrl = pictureUrl;
        updatedData['picture_url'] = pictureUrl;
      } else if (File(pictureUrl).existsSync()) {
        finalPictureUrl = await _uploadProfileImage(File(pictureUrl));
        updatedData['picture_url'] = finalPictureUrl;
      }
    }

    await _firestore
        .collection('users')
        .doc(currentUser.id)
        .update(updatedData);

    if (name?.trim().isNotEmpty == true) {
      await firebaseUser.updateDisplayName(name!.trim());
    }

    if (finalPictureUrl != null && finalPictureUrl.startsWith('http')) {
      await firebaseUser.updatePhotoURL(finalPictureUrl);
    }

    final updatedUser = UserModel(
      id: currentUser.id,
      name: updatedName,
      phoneNumber: updatedPhone,
      pictureUrl: finalPictureUrl ?? currentUser.pictureUrl,
      role: currentUser.role,
      email: updatedEmail,
      city: updatedCity,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
    );

    await _session.setCurrentUser(updatedUser);
    return updatedUser;
  }

  Future<String> _uploadProfileImage(File imageFile) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-signed-in',
        message: 'User must be signed in to upload a profile picture.',
      );
    }

    final fileName = imageFile.path.split(RegExp(r'[\\/]')).last;
    final storagePath =
        'users/${firebaseUser.uid}/profile_${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storageRef = _storage.ref().child(storagePath);

    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> signOut() async {
    try {
      final push = Get.find<PushNotificationService>();
      await push.clearToken();
      await push.unsubscribeFromTopics();
    } catch (e) {
      debugPrint('[AuthService] Push cleanup on signOut error: $e');
    }
    await _auth.signOut();
    await _session.clearSession();
  }
}
