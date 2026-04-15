import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_screen.dart'; // Ajustez le chemin si nécessaire

// --- Modèle de données pour un service ---
class Service {
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  const Service({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

// --- Écran affichant la liste des services ---
class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  // --- Données de démonstration ---
  final List<Service> services = const [
    Service(
      name: 'Coupe & Brushing',
      description: 'Une coupe moderne suivie d\'un brushing parfait pour un style impeccable.',
      price: 'À partir de 45€',
      imageUrl: 'https://images.pexels.com/photos/3065209/pexels-photo-3065209.jpeg',
    ),
    Service(
      name: 'Coloration & Soin',
      description: 'Une couleur vibrante et durable, accompagnée d\'un soin profond pour protéger vos cheveux.',
      price: 'À partir de 75€',
      imageUrl: 'https://images.pexels.com/photos/3993449/pexels-photo-3993449.jpeg',
    ),
    Service(
      name: 'Manucure Classique',
      description: 'Limage, soin des cuticules, et pose de vernis pour des mains élégantes.',
      price: '30€',
      imageUrl: 'https://images.pexels.com/photos/3997394/pexels-photo-3997394.jpeg',
    ),
     Service(
      name: 'Soin Capillaire Profond',
      description: 'Un traitement réparateur intensif pour redonner vie et brillance à vos cheveux.',
      price: '55€',
      imageUrl: 'https://images.pexels.com/photos/2896853/pexels-photo-2896853.jpeg',
    ),
     Service(
      name: 'Coiffure de Soirée',
      description: 'Un chignon élégant ou des ondulations glamour pour vos événements spéciaux.',
      price: 'À partir de 60€',
      imageUrl: 'https://images.pexels.com/photos/3738351/pexels-photo-3738351.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nos Prestations',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceCard(context, service);
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image ---
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.network(
              service.imageUrl,
              fit: BoxFit.cover,
               loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
              errorBuilder: (ctx, err, stack) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          // --- Contenu Texte ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.oswald(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // --- Prix et Bouton ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      service.price,
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BookingScreen(
                            preselectedService: service.name,
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Réserver'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
