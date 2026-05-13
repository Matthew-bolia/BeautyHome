import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_edit_specialist_screen.dart';

class ManageSpecialistsScreen extends StatelessWidget {
  const ManageSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les Spécialistes', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('specialists').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aucun spécialiste trouvé. Appuyez sur + pour en ajouter un.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final specialists = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: specialists.length,
            itemBuilder: (context, index) {
              final specialist = specialists[index];
              final data = specialist.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(data['imageUrl'] ?? ''),
                  ),
                  title: Text(data['name'] ?? 'Sans nom', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['role'] ?? 'Rôle non défini', style: const TextStyle(color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                        onPressed: () {
                           Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditSpecialistScreen(specialistDocument: specialist)));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteSpecialist(context, specialist.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddEditSpecialistScreen()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Ajouter un spécialiste',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _deleteSpecialist(BuildContext context, String specialistId) async {
    try {
      await FirebaseFirestore.instance.collection('specialists').doc(specialistId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Spécialiste supprimé avec succès'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
