import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart'; // Pour accéder au ThemeProvider

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres', style: GoogleFonts.lato()),
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: Text('Mode Sombre', style: GoogleFonts.lato(fontSize: 16)),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.dark
                  ? 'Activé'
                  : 'Désactivé',
            ),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
          // D'autres paramètres peuvent être ajoutés ici
        ],
      ),
    );
  }
}
