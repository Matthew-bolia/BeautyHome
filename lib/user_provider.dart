import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;

  String? _uid;
  String? _name;
  String? _photoURL;
  bool _isAdmin = false; // <-- NOUVEAU: Utilise un booléen pour le statut admin

  String? get uid => _uid;
  String? get name => _name;
  String? get photoURL => _photoURL;
  bool get isAdmin => _isAdmin; // <-- NOUVEAU: Getter direct

  UserProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      clearUser();
    } else {
      await _loadUserFromFirestore(user);
    }
  }

  Future<void> _loadUserFromFirestore(User user) async {
    _uid = user.uid;
    _name = user.displayName;
    _photoURL = user.photoURL;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      _name = data['name'] ?? _name;
      _photoURL = data['photoURL'] ?? _photoURL;
      // <-- NOUVEAU: Lit le champ booléen 'isAdmin'
      _isAdmin = data['isAdmin'] ?? false;
    } else {
      // Si le document n'existe pas, on le crée avec isAdmin: false
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _name,
        'photoURL': _photoURL,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        // <-- NOUVEAU: Définit le statut admin par défaut
        'isAdmin': false,
      });
      _isAdmin = false;
    }

    notifyListeners();
  }

  void clearUser() {
    _uid = null;
    _name = null;
    _photoURL = null;
    _isAdmin = false; // <-- NOUVEAU: Réinitialise au statut par défaut
    notifyListeners();
  }

  Future<void> updateUserPhoto(String newPhotoURL) async {
    if (_uid != null) {
      _photoURL = newPhotoURL;
      await FirebaseFirestore.instance.collection('users').doc(_uid!).update({
        'photoURL': newPhotoURL,
      });
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
