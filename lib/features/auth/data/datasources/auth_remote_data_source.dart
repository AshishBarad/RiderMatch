import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart' as domain;

abstract class AuthRemoteDataSource {
  Future<void> loginWithPhone(String phoneNumber);
  Future<domain.User> verifyOtp(String verificationId, String otp);
  Future<domain.User?> getCurrentUser();
  Stream<domain.User?> watchCurrentUser();
  Future<void> logout();
  String? getVerificationId();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Singleton pattern to preserve verification ID
  static final AuthRemoteDataSourceImpl _instance =
      AuthRemoteDataSourceImpl._internal();

  factory AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {
    if (firebaseAuth != null) {
      _instance._firebaseAuth = firebaseAuth;
    }
    if (firestore != null) {
      _instance._firestore = firestore;
    }
    return _instance;
  }

  AuthRemoteDataSourceImpl._internal()
    : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
      _firestore = FirebaseFirestore.instance;

  firebase_auth.FirebaseAuth _firebaseAuth;
  FirebaseFirestore _firestore;

  String? _verificationId;
  domain.User? _mockUser; // For bypass mode

  @override
  Future<void> loginWithPhone(String phoneNumber) async {
    // Format phone number to E.164 format (+91XXXXXXXXXX)
    final formattedPhone = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+91$phoneNumber';

    if (kDebugMode) {
      print('🔵 Sending OTP to: $formattedPhone');
    }

    // NETWORK BYPASS FOR TEST USER
    if (formattedPhone == '+919422123459') {
      if (kDebugMode) {
        print('⚡ BYPASS: Simulating OTP sent for test user');
      }
      _verificationId = 'bypass-verification-id';
      return;
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted:
          (firebase_auth.PhoneAuthCredential credential) async {
            if (kDebugMode) {
              print('✅ Auto-verification completed');
            }
            // Auto-verification (Android only)
            await _firebaseAuth.signInWithCredential(credential);
          },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        if (kDebugMode) {
          print('❌ Verification failed: ${e.message}');
        }
        throw Exception('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        if (kDebugMode) {
          print(
            '📱 Code sent! Verification ID: ${verificationId.substring(0, min(20, verificationId.length))}...',
          );
        }
        _verificationId = verificationId;
        if (kDebugMode) {
          print(
            '💾 Stored verification ID: ${_verificationId?.substring(0, min(20, _verificationId?.length ?? 0))}...',
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (kDebugMode) {
          print(
            '⏱️ Auto-retrieval timeout. Verification ID: ${verificationId.substring(0, min(20, verificationId.length))}...',
          );
        }
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  Future<domain.User> verifyOtp(String verificationId, String otp) async {
    try {
      if (kDebugMode) {
        print('🔐 Verifying OTP...');
      }

      // Use provided verificationId or the stored one
      final vid = verificationId.isNotEmpty ? verificationId : _verificationId;

      if (vid == 'bypass-verification-id') {
        if (otp == '123456') {
          if (kDebugMode) print('⚡ BYPASS: OTP Verified!');
          _mockUser = domain.User(
            id: 'test-user-id',
            phoneNumber: '+919422123459',
            fullName: 'Test User',
            isProfileComplete: true,
          );
          return _mockUser!;
        } else {
          throw Exception('Invalid OTP for test user');
        }
      }

      if (vid == null) {
        if (kDebugMode) {
          print('❌ No verification ID available!');
        }
        throw Exception('No verification ID available');
      }

      if (kDebugMode) {
        print(
          '✅ Using verification ID: ${vid.substring(0, min(20, vid.length))}...',
        );
        print('🔢 OTP code: $otp');
      }

      // Create credential
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      firebase_auth.User? firebaseUser;

      try {
        if (kDebugMode) {
          print('🔑 Credential created, signing in...');
        }
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );
        firebaseUser = userCredential.user;
      } catch (e) {
        // Workaround for PigeonUserDetails type error (known Firebase plugin issue)
        // It throws but the sign-in might have actually succeeded internally
        final errorStr = e.toString();
        if (errorStr.contains('PigeonUserDetails') ||
            errorStr.contains('List<Object?>') ||
            errorStr.contains('type cast')) {
          if (kDebugMode) {
            print(
              '⚠️ PigeonUserDetails error (known issue), checking current user...',
            );
          }

          // Wait a bit for auth state to propagate
          await Future.delayed(const Duration(milliseconds: 500));

          firebaseUser = _firebaseAuth.currentUser;

          if (firebaseUser != null) {
            if (kDebugMode) {
              print('✅ User authenticated despite error: ${firebaseUser.uid}');
            }
            // Proceed as if success
          } else {
            // Actually failed
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (firebaseUser == null) {
        if (kDebugMode) {
          print('❌ Sign in failed - no user');
        }
        throw Exception('Failed to sign in');
      }

      if (kDebugMode) {
        print('✅ Signed in successfully! UID: ${firebaseUser.uid}');
      }

      // Check if user document exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          print('📝 Creating new user document...');
        }
        // Create new user document
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'phoneNumber': firebaseUser.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'rideCount': 0,
          'followerCount': 0,
          'followingCount': 0,
        });

        if (kDebugMode) {
          print('✅ New user created');
        }
        // Return user with incomplete profile
        return domain.User(
          id: firebaseUser.uid,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          isProfileComplete: false,
        );
      }

      if (kDebugMode) {
        print('✅ Existing user found');
      }
      // User exists, fetch full profile
      final userData = userDoc.data()!;
      final hasFullName =
          userData['fullName'] != null &&
          (userData['fullName'] as String).isNotEmpty;

      return domain.User(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        fullName: userData['fullName'],
        isProfileComplete: hasFullName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      }
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw Exception('OTP expired. Please request a new code');
      }
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception: $e');
      }
      throw Exception('Authentication failed: $e');
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        // Check for mock user (bypass mode)
        if (_mockUser != null) {
          return _mockUser;
        }
        return null;
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;
      final hasFullName =
          userData['fullName'] != null &&
          (userData['fullName'] as String).isNotEmpty;

      return domain.User(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        fullName: userData['fullName'],
        isProfileComplete: hasFullName,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<domain.User?> watchCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(_mockUser);
      }

      // Listen to the document in real-time
      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return null;
            final userData = snapshot.data()!;
            return _userFromFirestore(
              firebaseUser.uid,
              firebaseUser.phoneNumber ?? '',
              userData,
            );
          });
    });
  }

  domain.User _userFromFirestore(
    String uid,
    String phoneNumber,
    Map<String, dynamic> data,
  ) {
    final hasFullName =
        data['fullName'] != null && (data['fullName'] as String).isNotEmpty;

    return domain.User(
      id: uid,
      phoneNumber: phoneNumber,
      fullName: data['fullName'],
      username: data['username'],
      photoUrl: data['photoUrl'],
      coverImageUrl: data['coverImageUrl'],
      age: data['age'],
      gender: data['gender'],
      vehicleManufacturer: data['vehicleManufacturer'],
      vehicleModel: data['vehicleModel'],
      vehicleRegNo: data['vehicleRegNo'],
      bloodGroup: data['bloodGroup'],
      emergencyContactName: data['emergencyContactName'],
      emergencyContactRelationship: data['emergencyContactRelationship'],
      emergencyContactNumber: data['emergencyContactNumber'],
      ridingPreferences: data['ridingPreferences'] != null
          ? List<String>.from(data['ridingPreferences'] as List)
          : [],
      rideDistancePreference:
          (data['rideDistancePreference'] as num?)?.toDouble() ?? 50.0,
      isProfileComplete: hasFullName,
      lastKnownLat: (data['lastKnownLat'] as num?)?.toDouble(),
      lastKnownLng: (data['lastKnownLng'] as num?)?.toDouble(),
    );
  }

  @override
  Future<void> logout() async {
    _mockUser = null;
    await _firebaseAuth.signOut();
  }

  @override
  String? getVerificationId() {
    return _verificationId;
  }

  int min(int a, int b) => a < b ? a : b;
}
