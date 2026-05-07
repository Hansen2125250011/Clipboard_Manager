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

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // Sync a single clip to Firestore
  Future<void> syncClip(String content) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('clips').add({
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'userEmail': user.email,
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
          'content': data['content'],
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Firebase Fetch Error: $e');
      return [];
    }
  }
}
