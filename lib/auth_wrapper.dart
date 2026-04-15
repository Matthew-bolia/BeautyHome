import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/email_verification_screen.dart';
import 'package:myapp/home_screen_skeleton.dart'; 
import 'home_screen.dart';
import 'auth_screen.dart';
import 'admin_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // On affiche le skeleton pendant la vérification initiale
          return const HomeScreenSkeleton();
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          
          final isGoogleProvider = user.providerData.any((userInfo) => userInfo.providerId == 'google.com');

          if (user.emailVerified || isGoogleProvider) {
            return RoleBasedWrapper(user: user);
          } else {
            return const EmailVerificationScreen();
          }
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

class RoleBasedWrapper extends StatelessWidget {
  final User user;
  const RoleBasedWrapper({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // On affiche aussi le skeleton ici, pendant la récupération du rôle
          return const HomeScreenSkeleton();
        }

        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Something went wrong.')));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const HomeScreen(); 
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String role = data['role'] ?? 'client';

        if (role == 'admin') {
          return const AdminDashboard();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
