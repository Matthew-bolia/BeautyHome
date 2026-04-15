import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart'; // Import de Publication
import 'add_publication_screen.dart';

class ManagePublicationsScreen extends StatefulWidget {
  const ManagePublicationsScreen({super.key});

  @override
  State<ManagePublicationsScreen> createState() => _ManagePublicationsScreenState();
}

class _ManagePublicationsScreenState extends State<ManagePublicationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les Publications', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('publications').orderBy('publicationDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune publication à gérer.'));
          }

          final publications = snapshot.data!.docs.map((doc) => Publication.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: publications.length,
            itemBuilder: (context, index) {
              final pub = publications[index];
              return ListTile(
                leading: Image.network(pub.publicationImageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(pub.userName),
                subtitle: Text('Publiée le ${pub.publicationDate.day}/${pub.publicationDate.month}/${pub.publicationDate.year}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // TODO: Logique de modification
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Logique de suppression
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPublicationScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Ajouter une publication',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
