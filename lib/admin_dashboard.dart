import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Admin', style: GoogleFonts.oswald()),
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildDashboardCard(
              context,
              icon: Icons.content_cut,
              title: 'Gérer les Services',
              onTap: () { /* TODO: Navigate to service management screen */ },
            ),
             _buildDashboardCard(
              context,
              icon: Icons.calendar_today,
              title: 'Gérer les RDV',
              onTap: () { /* TODO: Navigate to appointment management screen */ },
            ),
             _buildDashboardCard(
              context,
              icon: Icons.people,
              title: 'Gérer les Utilisateurs',
              onTap: () { /* TODO: Navigate to user management screen */ },
            ),
             _buildDashboardCard(
              context,
              icon: Icons.bar_chart,
              title: 'Statistiques',
              onTap: () { /* TODO: Navigate to statistics screen */ },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
