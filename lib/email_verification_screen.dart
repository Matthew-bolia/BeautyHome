import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth_wrapper.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _isEmailVerified = currentUser.emailVerified;

      if (!_isEmailVerified) {
        sendVerificationEmail();

        _timer = Timer.periodic(
          const Duration(seconds: 5),
          (_) => checkEmailVerified(),
        );
      }
    } 
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 15));
      if (mounted) {
        setState(() => _canResendEmail = true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail de vérification envoyé.'), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'envoi de l\'e-mail: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> checkEmailVerified() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await currentUser.reload();

    if (mounted) {
      setState(() {
        _isEmailVerified = currentUser.emailVerified;
      });

      if (_isEmailVerified) {
        _timer?.cancel();
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail vérifié avec succès !'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
       // Si pour une raison quelconque l'utilisateur est null, retour à la sécurité
      return const AuthWrapper();
    }

    return _isEmailVerified
        ? const AuthWrapper() // Laisser AuthWrapper décider (HomeScreen ou AdminDashboard)
        : Scaffold(
            appBar: AppBar(
              title: const Text("Vérification de l'E-mail"),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, size: 80, color: Colors.deepPurple),
                    const SizedBox(height: 24),
                    Text(
                      'Vérifiez votre boîte de réception',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Un e-mail de vérification a été envoyé à ${FirebaseAuth.instance.currentUser!.email}. Cliquez sur le lien pour activer votre compte.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('J\'ai vérifié, actualiser'),
                      onPressed: checkEmailVerified,
                       style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Renvoyer l\'e-mail'),
                      onPressed: _canResendEmail ? sendVerificationEmail : null,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    ),
                     const SizedBox(height: 24),
                     TextButton( 
                       onPressed: () {
                         _timer?.cancel();
                         FirebaseAuth.instance.signOut();
                       },
                       child: const Text('Annuler et se déconnecter', style: TextStyle(color: Colors.red)),
                      )
                  ],
                ),
              ),
            ),
          );
  }
}
