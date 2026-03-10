import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'services_page.dart'; // <-- IMPORTATION DE LA NOUVELLE PAGE

// --- Placeholder Screens (unchanged) ---
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recherche')),
    body: const Center(child: Text('Page de recherche')),
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications')),
    body: const Center(child: Text('Page de notifications')),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Paramètres')),
    body: const Center(child: Text('Page des paramètres')),
  );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('À propos')),
    body: const Center(child: Text('Page À propos')),
  );
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aide')),
    body: const Center(child: Text('Page d\'aide')),
  );
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Conditions d\'utilisation')),
    body: const Center(child: Text('Page des conditions d\'utilisation')),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _displayName;
  String? _email;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted && userDoc.exists) {
          setState(() {
            _displayName = userDoc.data()?['displayName'];
            _email = userDoc.data()?['email'];
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // --- MISE À JOUR DE LA LISTE DES WIDGETS ---
    final List<Widget> widgetOptions = <Widget>[
      _buildHomePageBody(),
      const ServicesPage(), // <-- INTÉGRATION DE LA PAGE DES SERVICES
      const Center(child: Text('Page Galerie : à construire')),
      const Center(child: Text('Page Contact : à construire')),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
            : _buildProfileMenu(context, themeProvider),
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut_outlined),
            activeIcon: Icon(Icons.content_cut),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Galerie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_outlined),
            activeIcon: Icon(Icons.contact_phone),
            label: 'Contact',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 40,
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.primary,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search logic
        },
      ),
    );
  }

  Widget _buildHomePageBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Catégories'),
          _buildCategoriesList(),
          const SizedBox(height: 24),
          _buildSectionTitle('Nos Services Populaires'),
          _buildServicesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const NetworkImage(
                'https://images.pexels.com/photos/3998414/pexels-photo-3998414.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'Style & Élégance',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                /* TODO: Navigate to appointment booking */
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Prendre Rendez-vous'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.oswald(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    final categories = ['Coupes', 'Coloration', 'Soins', 'Barbe', 'Maquillage'];
    final icons = [
      Icons.content_cut,
      Icons.brush,
      Icons.spa,
      Icons.face,
      Icons.color_lens,
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            width: 85,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: Icon(
                    icons[index],
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  categories[index],
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('services').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Une erreur est survenue.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucun service disponible pour le moment.'),
            ),
          );
        }

        final services = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index].data() as Map<String, dynamic>;
            final imageUrl =
                service['imageUrl'] as String? ??
                'https://via.placeholder.com/300x200.png?text=Image+non+disponible';
            final price = service['price'] is num
                ? (service['price'] as num).toDouble().toStringAsFixed(2)
                : 'N/A';

            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  /* TODO: Navigate to service detail page */
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'] ?? 'Service sans nom',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$price €',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileMenu(BuildContext context, ThemeProvider themeProvider) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'settings':
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            break;
          case 'about':
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
            break;
          case 'help':
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
            break;
          case 'terms':
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
            break;
          case 'logout':
            FirebaseAuth.instance.signOut();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName ?? 'Utilisateur',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _email ?? 'Aucun email',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          icon: Icons.settings_outlined,
          text: 'Paramètres',
          value: 'settings',
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 12),
              Text(
                themeProvider.themeMode == ThemeMode.dark
                    ? 'Mode Clair'
                    : 'Mode Sombre',
              ),
              const Spacer(),
              Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          icon: Icons.info_outline,
          text: 'À propos',
          value: 'about',
        ),
        _buildPopupMenuItem(
          icon: Icons.help_outline,
          text: 'Aide et support',
          value: 'help',
        ),
        _buildPopupMenuItem(
          icon: Icons.description_outlined,
          text: 'Conditions d\'utilisation',
          value: 'terms',
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          icon: Icons.logout,
          text: 'Déconnexion',
          value: 'logout',
          isDestructive: true,
        ),
      ],
      icon: Icon(
        Icons.account_circle,
        size: 28,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      tooltip: 'Profil',
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required IconData icon,
    required String text,
    required String value,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isDestructive ? Colors.red : null),
          ),
        ],
      ),
    );
  }
}
