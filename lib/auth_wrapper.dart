import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verify_code_screen.dart';
import 'widgets/skeleton_loader.dart'; // Importation corrigée
import 'home_screen.dart';
import 'auth_screen.dart';
import 'admin_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Future<void> _redirectResultFuture;

  @override
  void initState() {
    super.initState();
    _redirectResultFuture = _handleRedirectSignIn();
  }

  Future<void> _handleRedirectSignIn() async {
    try {
      await FirebaseAuth.instance.getRedirectResult();
    } catch (e) {
      debugPrint("Erreur lors de la récupération de la redirection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _redirectResultFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Correction de la coquille ici
          return const Scaffold(body: PinterestGridSkeleton());
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              // Correction de la coquille ici aussi
              return const Scaffold(body: PinterestGridSkeleton());
            }

            if (authSnapshot.hasData) {
              final user = authSnapshot.data!;
              final isGoogleProvider = user.providerData.any(
                (userInfo) => userInfo.providerId == 'google.com',
              );

              if (user.emailVerified || isGoogleProvider) {
                return RoleBasedWrapper(user: user);
              } else {
                // Note: Assurez-vous que VerifyCodeScreen gère correctement l'email
                return VerifyCodeScreen(email: user.email ?? '');
              }
            } else {
              return AuthScreen();
            }
          },
        );
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Et une dernière correction ici
          return const Scaffold(body: PinterestGridSkeleton());
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong.')),
          );
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
