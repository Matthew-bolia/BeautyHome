import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aide et support', style: GoogleFonts.lato())),
      body: const Center(child: Text('Contenu de la page d\'aide')),
    );
  }
}
