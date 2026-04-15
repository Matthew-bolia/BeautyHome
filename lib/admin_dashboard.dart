import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_publications_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Gérer les Publications',
        icon: Icons.article_outlined,
        color: Colors.blue.shade700,
        onTap: () {
          // Naviguer vers la page de gestion des publications
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManagePublicationsScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Gérer les Services',
        icon: Icons.content_cut_outlined,
        color: Colors.orange.shade700,
        onTap: () {
          // TODO: Naviguer vers la page de gestion des services
          print('Navigation vers la gestion des services');
        },
      ),
      DashboardItem(
        title: 'Gérer les Spécialistes',
        icon: Icons.people_alt_outlined,
        color: Colors.green.shade700,
        onTap: () {
          // TODO: Naviguer vers la page de gestion des spécialistes
          print('Navigation vers la gestion des spécialistes');
        },
      ),
      DashboardItem(
        title: 'Gérer les Clients',
        icon: Icons.manage_accounts_outlined,
        color: Colors.red.shade700,
        onTap: () {
          // TODO: Naviguer vers la page de gestion des clients
          print('Navigation vers la gestion des clients');
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Administrateur',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildDashboardCard(context, item);
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, DashboardItem item) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: item.color,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
