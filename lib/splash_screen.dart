import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // La bonne méthode
import 'package:beauty_home/onboarding_screen.dart';
import 'package:beauty_home/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  // Cette fonction lance les vérifications et retourne un résultat.
  Future<bool> _initializeApp() async {
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 3)), // Temps d'affichage minimum
      _performChecks(), // Les vraies vérifications, fiables cette fois
    ]);
    return results[1] as bool;
  }

  /// Vérifie la connexion et l'état de l'onboarding.
  Future<bool> _performChecks() async {
    // 1. Vérification de la connexion avec connectivity_plus
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Si pas de réseau, on lève une erreur que le FutureBuilder va attraper
      throw Exception('No connection');
    }

    // 2. Vérification du statut de l'accueil
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  void _navigate(bool onboardingComplete) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => onboardingComplete
                ? const AuthWrapper()
                : const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<bool>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // En cas d'erreur (pas de connexion), on affiche le widget d'erreur
              return _buildErrorWidget();
            } else {
              final onboardingComplete = snapshot.data ?? false;
              _navigate(onboardingComplete);
              // Et on continue d'afficher le chargement pendant la transition
              return _buildLoadingWidget();
            }
          }
          return _buildLoadingWidget();
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo.png', width: 250),
        const SizedBox(height: 80),
        const SpinKitThreeBounce(color: Colors.black, size: 40.0),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 70),
          const SizedBox(height: 25),
          const Text(
            'Pas de connexion Internet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text(
            'Veuillez vérifier votre connexion et réessayer.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                _initFuture = _initializeApp();
              });
            },
            child: const Text('Réessayer', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
