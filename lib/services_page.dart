import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_screen.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We are now fetching categories dynamically from a 'service_categories' collection
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('service_categories').orderBy('name').snapshots(),
      builder: (context, categorySnapshot) {
        if (categorySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (categorySnapshot.hasError) {
          return const Center(child: Text('Erreur de chargement des catégories.'));
        }
        if (!categorySnapshot.hasData || categorySnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucune catégorie de service trouvée.'));
        }

        final categories = categorySnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final categoryName = category['name'] as String;

            return _buildCategorySection(context, categoryName);
          },
        );
      },
    );
  }

  Widget _buildCategorySection(BuildContext context, String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
          child: Text(
            categoryName,
            style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        // Fetch services for this specific category
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .where('category', isEqualTo: categoryName)
              .snapshots(),
          builder: (context, serviceSnapshot) {
            if (serviceSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }
            if (serviceSnapshot.hasError) {
              return const Text('  Erreur de chargement des services.');
            }
            if (!serviceSnapshot.hasData || serviceSnapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('  Aucun service dans cette catégorie pour le moment.', style: TextStyle(fontStyle: FontStyle.italic)),
              );
            }

            final services = serviceSnapshot.data!.docs;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final service = services[index];
                final serviceData = service.data() as Map<String, dynamic>;
                final serviceName = serviceData['name'] as String? ?? 'Service inconnu';
                final servicePrice = (serviceData['price'] as num? ?? 0).toDouble();
                final serviceDescription = serviceData['description'] as String? ?? 'Aucune description.';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(serviceDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${servicePrice.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 16)),
                      const SizedBox(height: 4),
                      SizedBox(
                         width: 100, // Constrain button width
                         height: 35,
                         child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(
                                  serviceId: service.id,
                                  serviceName: serviceName,
                                  servicePrice: servicePrice,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold)
                          ),
                          child: const Text('Réserver'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
