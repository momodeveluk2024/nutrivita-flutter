import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import '../storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required ApiClient api, required SecureTokenStorage storage})
    : _api = api,
      _storage = storage;

  final ApiClient _api;
  final SecureTokenStorage _storage;
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AppUser? _user;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    // Wait for the first auth state event before returning,
    // so the router knows whether the user is logged in.
    final completer = Completer<void>();

    _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
      } else {
        try {
          await loadMe();
        } catch (_) {
          _user = null;
        }
      }
      _initialized = true;
      notifyListeners();
      if (!completer.isCompleted) completer.complete();
    });

    return completer.future;
  }

  Future<void> signup({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      await cred.user?.sendEmailVerification();
      await loadMe();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return; // User canceled sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
        _storage.clear(),
      ]);
    } catch (_) {}
    _user = null;
    _setLoading(false);
  }

  Future<void> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _firebaseAuth.confirmPasswordReset(code: token, newPassword: newPassword);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmail(String token) async {
    _setLoading(true);
    try {
      await _firebaseAuth.applyActionCode(token);
      await loadMe();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? sex,
    String? dateOfBirth,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
    String? pregnancyStatus,
  }) async {
    await _runAuthAction(() async {
      final response = await _api.patch(
        ApiEndpoints.meProfile,
        data: _withoutNulls({
          'display_name': displayName,
          'sex': sex,
          'date_of_birth': dateOfBirth,
          'height_cm': heightCm,
          'weight_kg': weightKg,
          'activity_level': activityLevel,
          'pregnancy_status': pregnancyStatus,
        }),
      );
      _user = AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
    });
  }

  Future<void> uploadAvatarBytes({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    await _runAuthAction(() async {
      final form = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: filename.trim().isEmpty ? 'avatar.jpg' : filename.trim(),
          contentType: DioMediaType.parse(contentType),
        ),
      });
      final response = await _api.postMultipart(ApiEndpoints.meAvatar, form);
      _user = AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
    });
  }

  Future<void> updatePreferences({
    String? units,
    String? locale,
    String? timezone,
    String? dietaryPattern,
    List<String>? allergens,
    List<String>? goals,
    Map<String, dynamic>? preferences,
  }) async {
    await _runAuthAction(() async {
      final response = await _api.patch(
        ApiEndpoints.mePreferences,
        data: _withoutNulls({
          'units': units,
          'locale': locale,
          'timezone': timezone,
          'dietary_pattern': dietaryPattern,
          'allergens': allergens,
          'goals': goals,
          'preferences': preferences,
        }),
      );
      _user = AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
    });
  }

  Future<void> completeOnboarding() async {
    await _runAuthAction(() async {
      final response = await _api.patch(ApiEndpoints.meOnboardingComplete);
      _user = AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
    });
  }

  Future<void> updateAppearance(String appearance) async {
    final merged = Map<String, dynamic>.from(_user?.preferences ?? const {});
    merged['appearance'] = appearance;
    await updatePreferences(preferences: merged);
  }

  Future<void> loadMe() async {
    if (_firebaseAuth.currentUser == null) return;
    try {
      final response = await _api.get(ApiEndpoints.me);
      _user = AppUser.fromJson(Map<String, dynamic>.from(response.data as Map));
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
      _error = null;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Map<String, dynamic> _withoutNulls(Map<String, dynamic> values) {
    return Map<String, dynamic>.fromEntries(
      values.entries.where((entry) => entry.value != null),
    );
  }
}
