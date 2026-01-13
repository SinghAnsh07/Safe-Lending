import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../crypto/rsa_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  UserModel? _currentUserModel;

  User? get currentUser => _currentUser;
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _loadUserModel(user.uid);
    } else {
      _currentUserModel = null;
    }
    // Schedule notifyListeners to run after the current synchronous code
    // to avoid "setState() called during build" error
    Future.microtask(() => notifyListeners());
  }

  Future<void> _loadUserModel(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  /// Register new user
  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return 'Failed to create user';
      }

      // Generate RSA key pair
      final keyPair = RSAService.generateKeyPair();
      final publicKeyPem = RSAService.publicKeyToPem(keyPair.publicKey);
      final privateKeyPem = RSAService.privateKeyToPem(keyPair.privateKey);

      // Save private key securely on device
      await StorageService.savePrivateKey(privateKeyPem);
      await StorageService.savePublicKey(publicKeyPem);
      await StorageService.saveUserId(user.uid);

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        publicKey: publicKeyPem,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      _currentUserModel = userModel;
      notifyListeners();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  /// Login user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return 'Login failed';
      }

      // Load user data
      await _loadUserModel(user.uid);
      await StorageService.saveUserId(user.uid);

      // Check if keys exist locally
      final hasKeys = await StorageService.hasKeys();
      if (!hasKeys) {
        // Keys might be lost, need to regenerate or recover
        return 'Security keys not found. Please contact support.';
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
    await StorageService.clearAllData();
    _currentUser = null;
    _currentUserModel = null;
    notifyListeners();
  }

  /// Check auth state
  Future<void> checkAuthState() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      await _loadUserModel(_currentUser!.uid);
    }
    // Schedule notifyListeners to run after the current synchronous code
    // to avoid "setState() called during build" error
    Future.microtask(() => notifyListeners());
  }

  /// Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return 'Failed to send reset email: $e';
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
