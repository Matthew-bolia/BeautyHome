# 📚 Guide de Gestion des Services du Salon

## Vue d'ensemble

Le nouveau système de gestion des services divise les services en deux catégories :

### 1. **Services du Salon** (Nouveau) - Collection `salonServices`
Services que le salon **propose réellement** aux clients, organisés par catégories prédéfinies avec plusieurs images.

### 2. **Services Génériques** (Ancien) - Collection `services`
Anciens services génériques (conservés pour compatibilité).

---

## 📋 Catégories Prédéfinies

L'admin peut choisir parmi **12 catégories** :

| Catégorie | Emoji | Description |
|-----------|-------|-------------|
| Coiffure Femme | 💇‍♀️ | Coupes, colorations et soins capillaires |
| Coiffure Hommes | 💇‍♂️ | Coupes et rasages |
| Coiffure Enfants | 👨‍🦱 | Coupes adaptées aux enfants |
| Manucure | 💅 | Soins et décoration des mains |
| Pédicure | 🦶 | Soins et décoration des pieds |
| Soins de Visage | ✨ | Nettoyage, gommage et hydratation |
| Massage | 💆 | Massage relaxant et thérapeutique |
| Nail Art & Décoration | 💎 | Décoration et dessin sur ongles |
| Sourcils | 🎭 | Épilation et mise en forme |
| Épilation à la Cire | 🔥 | Épilation complète ou partielle |
| Extensions & Poses | 💄 | Extensions de cheveux, cils, ongles |
| Maquillage | 💄 | Maquillage de jour, soirée, événement |

---

## 🔧 Comment Utiliser (Admin)

### Étape 1 : Accéder au Dashboard Admin
1. Allez à **Dashboard Administrateur**
2. Cliquez sur **"Services du Salon"**

### Étape 2 : Sélectionner une Catégorie
- Scroll horizontalement pour voir toutes les catégories
- Appuyez sur une catégorie pour la sélectionner (elle se met en surbrillance)
- Les services de cette catégorie s'affichent dessous

### Étape 3 : Ajouter un Service

#### 🖼️ Ajouter les Images (Obligatoire)
1. Appuyez sur **"Galerie"** ou **"Caméra"**
2. Sélectionnez/prenez une photo
3. L'image s'affiche en miniature
4. Répétez pour ajouter plusieurs images
5. Les images apparaîtront en **carrousel** pour les clients

#### 📝 Remplir les Informations
- **Nom du service** : Ex. "Coupe Dégradée"
- **Description** : Ex. "Coupe tendance avec dégradé progressif"
- **Prix (€)** : Ex. "35"
- **Durée (minutes)** : Ex. "45"

#### ✅ Enregistrer
Appuyez sur **"Enregistrer"**

### Étape 4 : Modifier ou Supprimer

- **Modifier** : Appuyez sur l'icône **crayon** pour éditer
- **Supprimer** : Appuyez sur l'icône **corbeille** (confirmation requise)

---

## 📱 Vue Client - Services Screen

Les clients voient :

1. **Filtre par catégories** en haut (scroll horizontal)
2. **Services de chaque catégorie** affichant :
   - **Carrousel d'images** (swipe pour voir toutes les photos)
   - **Nombre de photos** disponibles
   - **Nom et description** du service
   - **Prix et durée**
   - **Bouton "Réserver"** pour prendre rendez-vous

---

## 💾 Structure Firestore

### Collection : `salonServices`

```json
{
  "categoryId": "haircut_women",
  "name": "Coupe Dégradée",
  "description": "Coupe tendance avec dégradé progressif",
  "price": 35.0,
  "durationMinutes": 45,
  "images": [
    {
      "id": "uuid-1",
      "imageUrl": "https://...",
      "uploadedAt": "2024-01-15T10:30:00Z"
    },
    {
      "id": "uuid-2",
      "imageUrl": "https://...",
      "uploadedAt": "2024-01-15T10:31:00Z"
    }
  ],
  "createdAt": "2024-01-15T10:30:00Z",
  "isActive": true
}
```

---

## 🔐 Restrictions

- ✅ **Admin uniquement** : Créer, modifier, supprimer des services
- ✅ **Admin uniquement** : Ajouter/supprimer des images
- ✅ **Clients** : Voir les services et galerie d'images
- ✅ **Clients** : Filtrer par catégorie

---

## 💡 Conseils

1. **Images** : Ajoutez au moins 2-3 images par service pour plus d'attrait visuel
2. **Descriptions** : Soyez descriptif (ex. "avec traitement protéiné inclus")
3. **Prix** : Mettez à jour régulièrement selon vos tarifs
4. **Durée** : Soyez réaliste pour mieux gérer les rendez-vous
5. **Catégories** : Utilisez les catégories pertinentes pour mieux organiser

---

## 📲 Modèles de Données (Développeurs)

### ServiceImage
```dart
class ServiceImage {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;
}
```

### SalonService
```dart
class SalonService {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final List<ServiceImage> images;
  final DateTime createdAt;
  final bool isActive;
}
```

### ServiceCategory
```dart
class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
}
```

---

## 🎯 Fichiers Modifiés/Créés

- ✅ `lib/models/service_models.dart` - Modèles de données
- ✅ `lib/manage_salon_services_screen.dart` - Gestion des services (Admin)
- ✅ `lib/add_edit_salon_service_screen.dart` - Ajouter/modifier les services
- ✅ `lib/services_screen.dart` - Affichage des services aux clients
- ✅ `lib/admin_dashboard.dart` - Intégration au dashboard
- ✅ `pubspec.yaml` - Ajout du package `uuid`

---

## 🐛 Dépannage

**Problème** : Les images ne s'uploadent pas
- ✅ Vérifiez les permissions d'accès aux photos
- ✅ Vérifiez la connexion Internet
- ✅ Vérifiez les règles Firestore Storage

**Problème** : Les services n'apparaissent pas pour les clients
- ✅ Vérifiez que `isActive` est `true`
- ✅ Vérifiez que la catégorie correcte est sélectionnée
- ✅ Vérifiez les règles Firestore

---

## ✉️ Support

Pour toute question, consultez le code ou les modèles de données dans le projet.
