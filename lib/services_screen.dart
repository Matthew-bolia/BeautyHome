import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'models/service_models.dart';
import 'catalog_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search_sharp),
            onPressed: () => setState(() {}),
          ),
        ],
        title: Text(
          'Nos Catalogues de Services',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('serviceCategories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun catalogue disponible.'));
          }

          final displayCategories = snapshot.data!.docs
              .map((doc) => ServiceCategory.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final category = displayCategories[index];
              return _CatalogCard(
                category: category,
                firestore: _firestore,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CatalogDetailScreen(
                        categoryId: category.id,
                        categoryName: category.name,
                        categoryIcon: category.icon,
                        categoryIconAsset: category.iconAsset,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CatalogCard extends StatefulWidget {
  final ServiceCategory category;
  final FirebaseFirestore firestore;
  final VoidCallback onTap;
  const _CatalogCard({
    required this.category,
    required this.firestore,
    required this.onTap,
  });

  @override
  State<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<_CatalogCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('salonServices')
          .where('categoryId', isEqualTo: widget.category.id)
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<ServiceImage> images = [];
        int serviceCount = 0;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          serviceCount = snapshot.data!.docs.length;
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['images'] is List) {
              images.addAll(
                (data['images'] as List)
                    .map((m) => ServiceImage.fromMap(m as Map<String, dynamic>))
                    .toList(),
              );
            }
          }
        }

        String displayIcon = widget.category.icon;

        return GestureDetector(
          onTap: widget.onTap,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: Text(
                      displayIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    widget.category.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Catalogue'),
                ),
                // Media (Carousel)
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: images.isNotEmpty
                            ? images.length
                            : (widget.category.assetImages.isNotEmpty
                                  ? widget.category.assetImages.length
                                  : 1),
                        itemBuilder: (context, index) {
                          if (images.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: images[index].imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey[100]),
                            );
                          } else if (widget.category.assetImages.isNotEmpty) {
                            return CachedNetworkImage(
                              imageUrl: widget.category.assetImages[index],
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey[100]),
                            );
                          } else {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                      if (images.length > 1 ||
                          widget.category.assetImages.length > 1)
                        Positioned(
                          bottom: 12,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: images.isNotEmpty
                                ? images.length
                                : widget.category.assetImages.length,
                            effect: const ScrollingDotsEffect(
                              activeDotColor: Colors.white,
                              dotColor: Colors.white54,
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$serviceCount service${serviceCount > 1 ? 's' : ''} publié${serviceCount > 1 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            'Voir tout →',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
  }
}
