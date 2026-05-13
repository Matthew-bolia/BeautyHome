import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nous contacter', style: GoogleFonts.lato()),
      ),
      body: const Center(
        child: Text('Contenu de la page Nous contacter'),
      ),
    );
  }
}
