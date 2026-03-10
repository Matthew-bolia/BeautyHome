import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        // While waiting for connection, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If user is not signed in, show the login/register screen
        if (!snapshot.hasData) {
          return const AuthScreen(); 
        }

        // If user is signed in, check their role and show the appropriate screen
        return RoleBasedWrapper(user: snapshot.data!);
      },
    );
  }
}

// This widget checks the user's role and shows the correct screen
class RoleBasedWrapper extends StatelessWidget {
  final User user;
  const RoleBasedWrapper({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {

        // Handle loading state for the role check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Handle errors
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Something went wrong.')));
        }

        // This case handles a user authenticated with Firebase but not yet present in our 'users' collection.
        // It can happen with a fresh signup. Defaulting to the client view is a safe choice.
        if (!snapshot.hasData || !snapshot.data!.exists) {
           return const HomeScreen(); 
        }

        // Safely get user role from the document
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String role = data['role'] ?? 'client'; // Default to 'client' if role is null

        // Show the correct screen based on the role
        if (role == 'admin') {
          return const AdminDashboard(); // The admin interface
        } else {
          return const HomeScreen(); // The standard user interface
        }
      },
    );
  }
}
