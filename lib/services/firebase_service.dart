import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  // Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Email Sign-In Error: $e');
      rethrow;
    }
  }

  // Register with Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Email Registration Error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // Sync a single clip to Firestore (Disabled without Auth)
  Future<void> syncClip(String content) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('clips').add({
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userEmail': user.email,
        'isFavorite': false, // Default to false when first synced
      });
      debugPrint('Clip synced to Firebase');
    } catch (e) {
      debugPrint('Firebase Sync Error: $e');
    }
  }

  // Fetch all clips from Firestore for the current user
  Future<List<Map<String, dynamic>>> fetchAllClips() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('clips')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'content': data['content'],
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'isFavorite': data['isFavorite'] ?? false,
        };
      }).toList();
    } catch (e) {
      debugPrint('Firebase Fetch Error: $e');
      return [];
    }
  }
  
  // Update favorite status in Firestore
  Future<void> updateFavorite(String content, bool isFavorite) async {
    final user = currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('clips')
          .where('userId', isEqualTo: user.uid)
          .where('content', isEqualTo: content)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'isFavorite': isFavorite});
      }
    } catch (e) {
      debugPrint('Firebase Update Error: $e');
    }
  }
}
