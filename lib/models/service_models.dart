import 'package:cloud_firestore/cloud_firestore.dart';

// Modèle pour les catégories de services prédéfinies
class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String iconAsset;
  final List<String> assetImages;
  final String description;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.iconAsset = '',
    this.assetImages = const [],
    required this.description,
  });

  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      iconAsset: data['iconAsset'] ?? '',
      assetImages: List<String>.from(data['assetImages'] ?? []),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'iconAsset': iconAsset,
      'assetImages': assetImages,
      'description': description,
    };
  }

  static List<ServiceCategory> getPredefinedCategories() {
    return [
      ServiceCategory(
        id: 'haircut_women',
        name: 'Coiffure Femme',
        icon: '💇‍♀️',
        iconAsset: 'assets/images/femme.jpg',
        assetImages: [
          'assets/images/femme.jpg',
          'assets/images/coiffure_1.jpg', // Assurez-vous que ces fichiers existent
          'assets/images/coiffure_2.jpg',
        ],
        description: 'Coupes, colorations et soins capillaires pour femmes',
      ),
      ServiceCategory(
        id: 'haircut_men',
        name: 'Coiffure Hommes',
        icon: '💇‍♂️',
        iconAsset: 'assets/images/homme.jpg',
        assetImages: ['assets/images/homme.jpg'],
        description: 'Coupes et rasages pour hommes',
      ),
      ServiceCategory(
        id: 'haircut_children',
        name: 'Coiffure Enfants',
        icon: '👨‍🦱',
        iconAsset: 'assets/images/enfants.jpg',
        assetImages: ['assets/images/enfants.jpg'],
        description: 'Coupes adaptées aux enfants',
      ),
      ServiceCategory(
        id: 'manicure',
        name: 'Manucure',
        icon: '💅',
        iconAsset: 'assets/images/manucure.jpg',
        assetImages: ['assets/images/manucure.jpg'],
        description: 'Soins et décoration des ongles des mains',
      ),
      ServiceCategory(
        id: 'pedicure',
        name: 'Pédicure',
        icon: '🦶',
        iconAsset: 'assets/images/pedicure.jpg',
        assetImages: ['assets/images/pedicure.jpg'],
        description: 'Soins et décoration des ongles des pieds',
      ),
      ServiceCategory(
        id: 'facial_care',
        name: 'Soins de Visage',
        icon: '✨',
        iconAsset: 'assets/images/soin de visage.jpg',
        assetImages: ['assets/images/soin de visage.jpg'],
        description: 'Nettoyage, gommage et soins hydratants',
      ),
      ServiceCategory(
        id: 'massage',
        name: 'Massage',
        icon: '💆',
        iconAsset: 'assets/images/massage.jpg',
        assetImages: ['assets/images/massage.jpg'],
        description: 'Massage relaxant et thérapeutique',
      ),
      ServiceCategory(
        id: 'nail_art',
        name: 'Nail Art & Décoration',
        icon: '💎',
        iconAsset: 'assets/images/decoration.jpg',
        assetImages: ['assets/images/decoration.jpg'],
        description: 'Décoration et dessin sur ongles',
      ),
      ServiceCategory(
        id: 'eyebrow',
        name: 'Sourcils',
        icon: '🎭',
        iconAsset: 'assets/images/sourcil.jpg',
        assetImages: ['assets/images/sourcil.jpg'],
        description: 'Épilation et mise en forme des sourcils',
      ),
      ServiceCategory(
        id: 'waxing',
        name: 'Épilation à la Cire',
        icon: '🔥',
        iconAsset: 'assets/images/epilation.jpg',
        assetImages: ['assets/images/epilation.jpg'],
        description: 'Épilation complète ou partielle',
      ),
      ServiceCategory(
        id: 'extensions',
        name: 'Extensions & Poses',
        icon: '💄',
        iconAsset: 'assets/images/pose.jpg',
        assetImages: ['assets/images/pose.jpg'],
        description: 'Extensions de cheveux, cils et ongles',
      ),
      ServiceCategory(
        id: 'makeup',
        name: 'Maquillage',
        icon: '💄',
        iconAsset: 'assets/images/maquillage.jpg',
        assetImages: ['assets/images/maquillage.jpg'],
        description: 'Maquillage de jour, soirée ou événement',
      ),
    ];
  }
}

// Modèle pour les images du service
class ServiceImage {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;

  ServiceImage({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory ServiceImage.fromMap(Map<String, dynamic> map) {
    return ServiceImage(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      uploadedAt: map['uploadedAt'] is Timestamp
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'imageUrl': imageUrl, 'uploadedAt': uploadedAt};
  }
}

// Modèle pour les services du salon
class SalonService {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String currency;
  final List<ServiceImage> images;
  final DateTime createdAt;
  final bool isActive;

  SalonService({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.currency,
    required this.images,
    required this.createdAt,
    this.isActive = true,
  });

  factory SalonService.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<ServiceImage> images = [];
    if (data['images'] is List) {
      images = (data['images'] as List)
          .map((img) => ServiceImage.fromMap(img as Map<String, dynamic>))
          .toList();
    }

    return SalonService(
      id: doc.id,
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      durationMinutes: data['durationMinutes'] ?? 0,
      currency: data['currency'] ?? '\$',
      images: images,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'currency': currency,
      'images': images.map((img) => img.toMap()).toList(),
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  // Retourne la première image ou une image par défaut
  String get mainImageUrl => images.isNotEmpty ? images.first.imageUrl : '';

  // Retourne toutes les images
  List<String> get allImageUrls => images.map((img) => img.imageUrl).toList();
}
