import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conditions d\'utilisation', style: GoogleFonts.lato()),
      ),
      body: const Center(
        child: Text('Contenu de la page Conditions d\'utilisation'),
      ),
    );
  }
}
