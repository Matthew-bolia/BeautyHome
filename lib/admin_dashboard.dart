import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/skeleton_loader.dart';
import 'manage_publications_screen.dart';
import 'manage_salon_services_screen.dart';
import 'manage_specialists_screen.dart';
import 'manage_services_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = Future.delayed(
      const Duration(milliseconds: 300),
    ); // Réduit pour plus de fluidité
  }

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> items = [
      DashboardItem(
        title: 'Gérer les Publications',
        icon: Icons.article_outlined,
        color: Colors.blue.shade600,
        onTap: () {
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
        color: Colors.orange.shade600,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManageServicesScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Gérer les Spécialistes',
        icon: Icons.people_alt_outlined,
        color: Colors.green.shade600,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManageSpecialistsScreen(),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Gérer les Clients',
        icon: Icons.manage_accounts_outlined,
        color: Colors.red.shade600,
        onTap: () {
          // TODO: Naviguer vers la page de gestion des clients
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Écran non implémenté.')),
          );
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GridSkeleton(itemCount: 5);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.0,
              mainAxisSpacing: 14.0,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              return _buildDashboardCard(context, items[index]);
            },
          );
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
          padding: const EdgeInsets.all(14.0),
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
