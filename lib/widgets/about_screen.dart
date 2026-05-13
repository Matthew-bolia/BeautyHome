import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('À propos', style: GoogleFonts.lato()),
      ),
      body: const Center(
        child: Text('Contenu de la page À propos'),
      ),
    );
  }
}
