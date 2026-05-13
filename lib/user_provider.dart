import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;

  String? _uid;
  String? _displayName;
  String? _email;
  String? _photoURL;
  bool _isAdmin = false;

  String? get uid => _uid;
  String? get displayName => _displayName;
  String? get email => _email;
  String? get photoURL => _photoURL;
  bool get isAdmin => _isAdmin;

  UserProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  get name => null;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _clearUser();
    } else {
      await _loadUserFromFirestore(user);
    }
  }

  Future<void> _loadUserFromFirestore(User user) async {
    _uid = user.uid;
    _email = user.email; // Chargé depuis l'objet User de Auth

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      _displayName = data['displayName'] ?? user.displayName; // Prend depuis Firestore, sinon depuis Auth
      _photoURL = data['photoURL'] ?? user.photoURL;
      _isAdmin = data['isAdmin'] ?? false;
    } else {
      // Si le document n'existe pas, on le crée avec les infos de Auth
      _displayName = user.displayName;
      _photoURL = user.photoURL;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _displayName,
        'email': _email,
        'photoURL': _photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });
      _isAdmin = false;
    }

    notifyListeners();
  }

  void updateDisplayName(String newName) {
    if (_uid != null) {
      _displayName = newName;
      notifyListeners();
    }
  }

  void updatePhotoUrl(String newPhotoURL) {
    if (_uid != null) {
      _photoURL = newPhotoURL;
      notifyListeners();
    }
  }

  void _clearUser() {
    _uid = null;
    _displayName = null;
    _email = null;
    _photoURL = null;
    _isAdmin = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
