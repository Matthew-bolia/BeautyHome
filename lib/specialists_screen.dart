import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_screen.dart'; // Ajustez le chemin si besoin

// --- Modèle de données pour un spécialiste ---
class Specialist {
  final String name;
  final String role;
  final String imageUrl;

  const Specialist({
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}

// --- Écran affichant la liste des spécialistes ---
class SpecialistsScreen extends StatelessWidget {
  const SpecialistsScreen({super.key});

  // --- Données de démonstration (cohérentes avec booking_screen.dart) ---
  final List<Specialist> specialists = const [
    Specialist(
      name: 'Isabelle Fontaine',
      role: 'Directrice artistique',
      imageUrl:
          'https://images.pexels.com/photos/1181690/pexels-photo-1181690.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    Specialist(
      name: 'Marcus Dupont',
      role: 'Coloriste expert',
      imageUrl:
          'https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    Specialist(
      name: 'Sophie Leblanc',
      role: 'Styliste & visagiste',
      imageUrl:
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    Specialist(
      name: 'Théo Bernard',
      role: 'Barbier & coiffeur homme',
      imageUrl:
          'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notre Équipe',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Ajustez pour le design souhaité
        ),
        itemCount: specialists.length,
        itemBuilder: (context, index) {
          final specialist = specialists[index];
          return _buildSpecialistCard(context, specialist);
        },
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context, Specialist specialist) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BookingScreen(preselectedSpecialistName: specialist.name, preselectedService: '',),
      )),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Image ---
            Expanded(
              child: Image.network(
                specialist.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) => progress == null
                    ? child
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey, size: 40)),
              ),
            ),
            // --- Contenu Texte ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    specialist.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialist.role,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
