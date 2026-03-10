# Blueprint de l'Application "Salon de Coiffure"

## Vue d'ensemble

Cette application est une plateforme pour un salon de coiffure, conçue pour servir à la fois les clients et le personnel administratif. Elle dispose de deux rôles principaux avec des permissions distinctes : Client et Administrateur.

---

## 1. Style, Design et Fonctionnalités Actuelles

### Design et Thème
- **Thème :** L'application supporte un mode clair et un mode sombre, gérés par `ThemeProvider`.
- **Polices :** Utilisation de `google_fonts` pour une typographie élégante (`Playfair Display`, `Oswald`, `Lato`).
- **Style Visuel :** Design moderne avec une section "héro" (image d'en-tête), des cartes de service visuelles, et une barre de navigation inférieure.

### Fonctionnalités Implémentées
- **Écran de Démarrage (`SplashScreen`) :** Un écran d'accueil temporaire au lancement.
- **Page d'Accueil (`HomeScreen`) :**
    - **Navigation :** Une barre de navigation inférieure (`BottomNavigationBar`) avec les sections : Accueil, Services, Galerie, Contact.
    - **Contenu :** Une section héro visuelle, une grille présentant les services sous forme de cartes (`Card`), et un bouton d'appel à l'action "Prendre Rendez-vous".
- **Gestion du Thème :** Un bouton dans l'AppBar permet de basculer entre le mode clair et le mode sombre.

---

## 2. Plan pour la Prochaine Étape : Implémentation des Rôles (Client/Admin)

### Objectif
Mettre en place un système d'authentification et de gestion des rôles pour différencier les fonctionnalités accessibles aux clients et aux administrateurs.

### Plan Détaillé

**A. Authentification et Gestion des Rôles**
1.  **Dépendances Firebase :** Intégrer `firebase_auth` pour la connexion/inscription et `cloud_firestore` pour la base de données.
2.  **Flux d'Authentification :**
    - Le flux de l'application sera : `SplashScreen` -> `AuthWrapper`.
    - `AuthWrapper` vérifiera l'état de connexion de l'utilisateur.
        - **Non connecté :** Redirige vers `AuthScreen` (connexion / inscription).
        - **Connecté :** Lit le rôle de l'utilisateur depuis Firestore et le redirige vers l'écran approprié.
3.  **Gestion des Rôles :**
    - Le rôle (`client` ou `admin`) sera assigné lors de l'inscription. Pour la sécurité, l'assignation du rôle `admin` se fera manuellement via la console Firebase dans un premier temps.

**B. Modèle de Données (Firestore)**
- **Collection `users` :**
    - `uid` (string)
    - `email` (string)
    - `displayName` (string)
    - `role` (string: 'client' | 'admin')
- **Collection `services` :**
    - `serviceId` (string)
    - `name` (string)
    - `description` (string)
    - `price` (number)
    - `imageUrl` (string)
    - `createdBy` (string: `uid` de l'admin)
- **Collection `appointments` :**
    - `appointmentId` (string)
    - `userId` (string: `uid` du client)
    - `serviceId` (string)
    - `date` (timestamp)
    - `status` (string: 'pending' | 'confirmed' | 'cancelled')

**C. Différenciation de l'Interface Utilisateur**

- **Interface Administrateur :**
    - Un tableau de bord (`AdminDashboard`) permettant de :
        - **Gérer les Services :** Créer, voir, modifier et supprimer des services.
        - **Gérer les Rendez-vous :** Voir les demandes des clients, les accepter ou les refuser.
        - **Gérer les Utilisateurs :** Voir la liste des clients et potentiellement les bloquer.
- **Interface Client (`UserHomeScreen`) :**
    - Voir la liste des services publiés par les administrateurs.
    - Cliquer sur un service pour voir les détails.
    - Soumettre une demande de rendez-vous pour un service.
