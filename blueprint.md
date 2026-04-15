# Blueprint de l'Application "Beauty Home"

## Vue d'ensemble

Cette application est une plateforme pour un salon de beauté et de coiffure, conçue pour servir à la fois les clients et le personnel administratif. Elle dispose de deux rôles principaux avec des permissions distinctes : **Client** et **Administrateur**. L'objectif est de fournir une vitrine élégante pour les services et de faciliter la prise de rendez-vous et la gestion du salon.

---

## 1. Style, Design et Fonctionnalités Actuelles

### Design et Thème
- **Thème :** L'application supporte un mode clair et un mode sombre, gérés par `ThemeProvider`.
- **Polices :** Utilisation de `google_fonts` pour une typographie élégante (`Playfair Display`, `Oswald`, `Lato`, `Cormorant Garamond`, `Inter`).
- **Style Visuel :** Design moderne et épuré inspiré de Pinterest, avec un fil d'actualité de publications (images de réalisations), des cartes de service, et des modales interactives.
- **Écran de Profil :** Une page dédiée où les utilisateurs peuvent voir et modifier leurs informations de base (nom, photo).

### Fonctionnalités Implémentées
- **Authentification :** Système de connexion/inscription complet via Firebase Auth (Email/Google).
- **Page d'Accueil (`HomeScreen`) :**
    - **Fil d'actualité :** Affichage de publications sous forme de grille "Pinterest".
    - **Recherche :** Filtrage des publications par nom d'utilisateur.
    - **Navigation :** Un menu latéral (`Drawer`) permet d'accéder aux différentes sections.
- **Gestion du Profil :**
    - Modification du nom d'affichage.
    - Changement de la photo de profil via la galerie ou l'appareil photo (`image_picker`), uploadée sur Firebase Storage.
- **Prise de Rendez-vous (`BookingScreen`) :** Un formulaire fonctionnel pour la prise de rendez-vous.
- **Système de Rôles :**
    - Le rôle `isAdmin` est lu depuis Firestore (`users/{uid}`).
    - Un lien vers un `AdminDashboard` est conditionnellement affiché dans le menu pour les administrateurs.

---

## 2. Plan de Développement : Prochaines Fonctionnalités

### A. Refonte de la Gestion de Contenu (Admin)

L'objectif est de permettre aux administrateurs de gérer tout le contenu dynamique de l'application directement depuis le `AdminDashboard`, sans avoir à modifier le code.

#### **1. Gestion des Publications (Fil d'actualité)**
- **Ce qui existe :** Les publications sont actuellement codées en dur dans `home_screen.dart`.
- **Ce qui sera fait :**
    - **Backend :** Créer une collection `publications` dans Firestore pour stocker les informations de chaque post (URL de l'image, nom de l'auteur, date, etc.).
    - **Frontend (Admin) :** Dans le dashboard, créer une interface pour :
        - **Ajouter** une nouvelle publication (uploader une image, saisir les détails).
        - **Modifier** les informations d'une publication existante.
        - **Supprimer** une publication.
    - **Frontend (Client) :** `HomeScreen` lira et affichera le flux de publications directement depuis Firestore.

#### **2. Gestion des Services**
- **Ce qui existe :** Les services sont codés en dur dans `services_screen.dart`.
- **Ce qui sera fait :**
    - **Backend :** Créer une collection `services` dans Firestore.
    - **Frontend (Admin) :** Dans le dashboard, créer une interface pour ajouter, modifier et supprimer des services (nom, description, prix, image).
    - **Frontend (Client) :** La page des services lira les données depuis Firestore.

#### **3. Gestion des Spécialistes**
- **Ce qui existe :** Les spécialistes sont codés en dur dans `specialists_screen.dart`.
- **Ce qui sera fait :**
    - **Backend :** Créer une collection `specialists` dans Firestore.
    - **Frontend (Admin) :** Dans le dashboard, créer une interface pour ajouter, modifier et supprimer des spécialistes (nom, rôle, photo).
    - **Frontend (Client) :** La page des spécialistes lira les données depuis Firestore.

### B. Gestion des Utilisateurs (Admin)

- **Ce qui sera fait :**
    - **Backend & Frontend (Admin) :** Créer une section "Gérer les Clients" dans le dashboard.
        - Lister tous les utilisateurs depuis la collection `users` de Firestore.
        - Permettre à un admin de **supprimer** un utilisateur (suppression de son document Firestore et de son compte Firebase Auth).
        - Permettre à un admin de **"bloquer"** un utilisateur (en ajoutant un champ `isBlocked: true` à son document, ce qui pourrait l'empêcher de se connecter ou d'utiliser certaines fonctionnalités).

### C. Fonctionnalités Client

- **Ce qui sera fait :**
    - **Enregistrement d'images :** Sur chaque publication du fil d'actualité, ajouter une option (par exemple, un bouton "télécharger") pour que le client puisse enregistrer l'image directement dans la galerie de son téléphone. Cela nécessitera l'utilisation de packages comme `image_gallery_saver` et `dio` (pour télécharger l'image depuis son URL).
