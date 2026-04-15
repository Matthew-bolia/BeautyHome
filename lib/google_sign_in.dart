import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const String webClientId =
    "764375548972-j091j9ibgcn3ldj4atn2es3j5o89h25e.apps.googleusercontent.com";

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email'],
  clientId: kIsWeb ? webClientId : null,
);

Future<void> handleGoogleSignIn(BuildContext context) async {
  final auth = FirebaseAuth.instance;

  try {
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      await auth.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
    }
    // La création de l'utilisateur est maintenant gérée par UserProvider.
    // Aucune action supplémentaire n'est nécessaire ici.

  } on FirebaseAuthException catch (e) {
    String message = 'Une erreur d\'authentification Google est survenue.';
    if (e.code == 'popup-blocked-by-browser') {
      message =
          'Le pop-up de connexion a été bloqué par le navigateur. Veuillez autoriser les pop-ups pour ce site.';
    } else if (e.code == 'popup-closed-by-user') {
      message = 'La fenêtre de connexion a été fermée.';
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  } catch (e, s) {
    developer.log(
      'Erreur Google Sign-In inattendue',
      name: 'GoogleSignIn',
      error: e,
      stackTrace: s,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : ${e.toString()}',
          ), 
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

Widget buildGoogleSignInButton(BuildContext context, VoidCallback onPressed) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
    label: const Text(
      'Continuer avec Google',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      side: BorderSide(color: Colors.white.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Widget buildSocialDivider() {
  return Row(
    children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'OU',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
    ],
  );
}
