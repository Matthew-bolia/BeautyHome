# 🏗️ Architecture du Système de Services - Schéma Complet

## Vue Générale de l'Application

```
┌─────────────────────────────────────────────────────────┐
│                   BEAUTY HOME APP                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┬──────────────────┬─────────────┐ │
│  │    CLIENT        │    SPECIALIST    │    ADMIN    │ │
│  └──────────────────┴──────────────────┴─────────────┘ │
│         │                    │                 │       │
│         ▼                    ▼                 ▼       │
│  ┌──────────────────────────────────────────────────┐  │
│  │            HOME SCREEN / NAVIGATION             │  │
│  └──────────────────────────────────────────────────┘  │
│         │                    │                 │       │
│    Services            Bookings          Dashboard    │
│         │                    │                 │       │
│         ▼                    ▼                 ▼       │
│  ┌──────────────────────────────────────────────────┐  │
│  │    Services_Screen    Booking_Screen  Admin_Board│ │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Système de Gestion des Services - Architecture Détaillée

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FIRESTORE DATABASE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │              Collection: salonServices                        │ │
│  ├───────────────────────────────────────────────────────────────┤ │
│  │  Doc: service_001                                             │ │
│  │  ├─ categoryId: "haircut_women"                              │ │
│  │  ├─ name: "Coupe Dégradée"                                  │ │
│  │  ├─ price: 35.0                                             │ │
│  │  ├─ images: [                                               │ │
│  │  │  ├─ { id, imageUrl, uploadedAt }                         │ │
│  │  │  └─ { id, imageUrl, uploadedAt }                         │ │
│  │  ├─ durationMinutes: 45                                     │ │
│  │  └─ isActive: true                                          │ │
│  │                                                               │ │
│  │  Doc: service_002, service_003, ...                          │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │         Collection: serviceCategories                         │ │
│  ├───────────────────────────────────────────────────────────────┤ │
│  │  Doc: haircut_women                                           │ │
│  │  ├─ name: "Coiffure Femme"                                  │ │
│  │  ├─ icon: "💇‍♀️"                                              │ │
│  │  └─ description: "..."                                       │ │
│  │                                                               │ │
│  │  Doc: haircut_men, manicure, massage, ...                    │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Flux de Données - CLIENT (Affichage des Services)

```
┌───────────────────────────────────────────────────────────────┐
│ CLIENT OUVRE L'APP                                            │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ services_screen.dart                                          │
│ - Récupère les catégories prédéfinies (12)                   │
│ - Affiche les catégories en scroll horizontal                 │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ CLIENT SÉLECTIONNE UNE CATÉGORIE                              │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ StreamBuilder Query Firestore                                 │
│ - WHERE categoryId = selected                                │
│ - WHERE isActive = true                                      │
│ - ORDER BY name                                              │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ Liste des Services (SalonService)                            │
│ Pour chaque service:                                          │
│ - PageView carrousel d'images                                │
│ - Nombre d'images                                            │
│ - Nom, Description, Prix, Durée                             │
│ - Bouton "Réserver"                                          │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ CLIENT SWIPE DANS LE CARROUSEL (PageView)                     │
│ - Voir les images du service                                 │
│ - Comprendre mieux le service                                │
└───────────────────────────────────────────────────────────────┘
```

---

## Flux de Données - ADMIN (Gestion des Services)

```
┌───────────────────────────────────────────────────────────────┐
│ ADMIN OUVRE LE DASHBOARD                                      │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ admin_dashboard.dart                                          │
│ - 5 tuiles d'options                                         │
│ - "Services du Salon" (nouveau)                              │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ ADMIN CLIQUE SUR "Services du Salon"                          │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ manage_salon_services_screen.dart                             │
│ - Affiche les 12 catégories en scroll horizontal              │
│ - Catégorie sélectionnée = surbrillance                       │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ ADMIN SÉLECTIONNE UNE CATÉGORIE                               │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ StreamBuilder Query Firestore (salonServices)                 │
│ - WHERE categoryId = selected                                │
│ - ORDER BY name                                              │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ Liste des Services avec Actions                              │
│ Pour chaque service:                                          │
│ - Aperçu des images (slider)                                │
│ - Nom, Prix, Durée                                          │
│ - Bouton MODIFIER (✏️)                                       │
│ - Bouton SUPPRIMER (🗑️)                                      │
│ - Nombre d'images existantes                                 │
│ - FAB (+) pour ajouter un nouveau                            │
└───────────────────────────────────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
         ▼                  ▼                  ▼
    AJOUTER NOUVEAU    MODIFIER EXISTANT    SUPPRIMER
         │                  │                  │
         └──────────────────┴──────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│ add_edit_salon_service_screen.dart                            │
│                                                               │
│ 1. AJOUTER IMAGES (Obligatoire)                              │
│    - Galerie ou Caméra                                       │
│    - Images multiples (max?)                                 │
│    - Grille 2x2 avec aperçu                                  │
│    - Bouton X pour supprimer une image                       │
│                                                               │
│ 2. REMPLIR LES INFOS                                         │
│    - Nom (TextFormField)                                     │
│    - Description (TextFormField)                             │
│    - Prix (TextFormField, number)                            │
│    - Durée (TextFormField, number)                           │
│                                                               │
│ 3. ENREGISTRER                                               │
│    - Upload des images vers Firebase Storage                 │
│    - Génération d'URLs Cloudinary                            │
│    - Création/Update du document Firestore                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

---

## Modèles de Données - Diagramme de Classes

```
┌─────────────────────────┐
│   ServiceCategory       │
├─────────────────────────┤
│ - id: String            │
│ - name: String          │
│ - icon: String          │
│ - description: String   │
├─────────────────────────┤
│ + fromFirestore()       │
│ + toFirestore()         │
│ + getPredefined()       │
└─────────────────────────┘
          △
          │ has 12
          │
         ┌┴────────────────────────────┐
         │ Coiffure Femme              │
         │ Coiffure Hommes             │
         │ Coiffure Enfants            │
         │ Manucure                    │
         │ ... (8 autres)              │
         └─────────────────────────────┘


┌─────────────────────────────┐
│    ServiceImage             │
├─────────────────────────────┤
│ - id: String (UUID)         │
│ - imageUrl: String          │
│ - uploadedAt: DateTime      │
├─────────────────────────────┤
│ + fromMap()                 │
│ + toMap()                   │
└─────────────────────────────┘
          △
          │ has N
          │
┌─────────────────────────────┐
│    SalonService             │
├─────────────────────────────┤
│ - id: String                │
│ - categoryId: String        │
│ - name: String              │
│ - description: String       │
│ - price: double             │
│ - durationMinutes: int      │
│ - images: List<ServiceImage>│
│ - createdAt: DateTime       │
│ - isActive: bool            │
├─────────────────────────────┤
│ + fromFirestore()           │
│ + toFirestore()             │
│ + mainImageUrl              │
│ + allImageUrls              │
└─────────────────────────────┘
```

---

## Arborescence des Fichiers - Structure du Projet

```
lib/
├── models/
│   └── service_models.dart ........................ (NEW)
│       ├── ServiceCategory (12 prédéfinies)
│       ├── ServiceImage
│       └── SalonService
│
├── services_screen.dart ........................... (MODIFIÉ)
│   ├── Filtre horizontal par catégories
│   ├── PageView carrousel d'images
│   └── Liste avec StreamBuilder
│
├── manage_salon_services_screen.dart ............. (NEW)
│   ├── Sélection de catégorie
│   ├── Liste des services filtrés
│   └── Boutons MODIFIER/SUPPRIMER
│
├── add_edit_salon_service_screen.dart ............ (NEW)
│   ├── Gestion multi-images
│   ├── GridView d'images
│   ├── Formulaire de saisie
│   └── Upload et sauvegarde
│
├── admin_dashboard.dart ........................... (MODIFIÉ)
│   ├── Nouvel élément "Services du Salon"
│   └── Import ManageSalonServicesScreen
│
├── manage_services_screen.dart ................... (ANCIEN - Conservé)
└── services/
    └── image_upload_service.dart ................. (EXISTANT)

docs/
├── SERVICES_MANAGEMENT_GUIDE.md .................. (NEW)
├── FIRESTORE_SECURITY_RULES.txt .................. (NEW)
├── INITIALIZE_CATEGORIES.txt ..................... (NEW)
├── IMPLEMENTATION_SUMMARY.md ..................... (NEW)
└── ARCHITECTURE.md ............................... (THIS FILE)
```

---

## Processus d'Upload d'Image

```
┌─────────────────────────────────────────┐
│ Admin sélectionne une image             │
│ (Galerie ou Caméra)                     │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ ImagePickerImage picker                 │
│ retourne File                           │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ File stocké localement dans List         │
│ Affichage en GridView avec aperçu       │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Admin clique sur "Enregistrer"           │
└─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌──────────────────┐   ┌──────────────────┐
│ Anciennes Images │   │ Nouvelles Images │
│ (Réseau)         │   │ (Fichiers)       │
│ ✅ Gardées        │   │ 🚀 Uploadées    │
└──────────────────┘   └──────────────────┘
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ ImageUploadService.uploadImage()        │
│ - Compress l'image                      │
│ - Upload vers Firebase Storage/Cloudinary
│ - Retourne l'URL de l'image             │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Créer ServiceImage avec :               │
│ - id: UUID                              │
│ - imageUrl: URL retournée               │
│ - uploadedAt: Maintenant                │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Ajouter à la liste images du service    │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│ Sauvegarder le document SalonService    │
│ dans Firestore avec toutes les images   │
└─────────────────────────────────────────┘
```

---

## Règles de Sécurité - Matrice d'Accès

```
                    CRÉER   LIRE    MODIFIER SUPPRIMER
salonServices
├─ Admin           ✅      ✅      ✅       ✅
├─ Client          ❌      ✅*     ❌       ❌
└─ Non-connecté    ❌      ✅*     ❌       ❌
   (* isActive = true)

services (ancien)
├─ Admin           ✅      ✅      ✅       ✅
├─ Client          ❌      ✅      ❌       ❌
└─ Non-connecté    ❌      ✅      ❌       ❌

users
├─ Admin           ✅      ✅      ✅       ✅
├─ Client/Self     ❌      ✅      ✅**     ❌
└─ Non-connecté    ❌      ❌      ❌       ❌
   (**Données propres seulement)
```

---

## Workflow Complet - Cas d'Usage Principal

```
SCÉNARIO: Admin ajoute un service de coiffure femme avec 3 images

1. Admin se connecte
                    │
                    ▼
2. Va au Dashboard
                    │
                    ▼
3. Clique sur "Services du Salon"
   → Ouvre: manage_salon_services_screen
                    │
                    ▼
4. Scroll et sélectionne "Coiffure Femme" (💇‍♀️)
   → La catégorie se met en surbrillance
                    │
                    ▼
5. Clique sur le FAB (+)
   → Ouvre: add_edit_salon_service_screen
                    │
                    ▼
6. Ajoute 3 images:
   - Clique Galerie → Choisit image 1
   - Clique Galerie → Choisit image 2
   - Clique Caméra → Prend photo
   → 3 images dans la GridView
                    │
                    ▼
7. Remplit le formulaire:
   - Nom: "Coupe Dégradée"
   - Description: "Coupe tendance..."
   - Prix: "35"
   - Durée: "45"
                    │
                    ▼
8. Clique "Enregistrer"
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    Image 1    Image 2    Image 3
      (Upload vers Firebase Storage)
        │           │           │
        └───────────┼───────────┘
                    │
                    ▼
            Créer ServiceImage x3
                    │
                    ▼
    Créer SalonService document
                    │
                    ▼
           Save vers Firestore
                    │
                    ▼
        Pop() → Revenir à la liste
                    │
                    ▼
     Le service apparaît dans la liste
     avec aperçu des 3 images
                    │
                    ▼
          CLIENT VOIT LE SERVICE
          avec carrousel d'images
```

---

## Performance & Optimisation

```
┌─────────────────────────────────┐
│ Optimisations Implémentées      │
├─────────────────────────────────┤
│ ✅ Lazy loading des images      │
│    → CachedNetworkImage          │
│                                 │
│ ✅ Pagination StreamBuilder     │
│    → Requêtes filtrées           │
│                                 │
│ ✅ Compression d'images         │
│    → ImageUploadService          │
│                                 │
│ ✅ PageView pour carrousel      │
│    → Smooth scroll               │
│                                 │
│ ✅ Connexion une seule fois     │
│    → isAdmin stocké localement   │
│                                 │
│ ✅ Batch operations             │
│    → Plusieurs images à la fois  │
└─────────────────────────────────┘
```

---

**Créé le 24 Avril 2026**
**Système: Beauty Home Services Management v1.0**
