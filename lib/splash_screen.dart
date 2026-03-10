import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 10),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ), // Navigate to AuthWrapper
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.network(
                'https://media.istockphoto.com/id/938560732/fr/vectoriel/symbole-de-ciseaux-et-fille.jpg?s=2048x2048&w=is&k=20&c=R0i_vtF8_jD1OyRL3SkCHIeOtLnHLX4iwFMNGuh3OQI=',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 50),
            const SpinKitChasingDots(color: Colors.black, size: 50.0),
          ],
        ),
      ),
    );
  }
}
