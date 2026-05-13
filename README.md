 BeautyHome

 Application mobile de réservation de services de beauté à domicile.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)

Présentation

BeautyHome est une application mobile qui permet aux utilisateurs de réserver des prestations de beauté directement à domicile. Les professionnels peuvent gérer leurs services, leurs disponibilités et leurs spécialistes via une interface d'administration intégrée.

Stack technique

Couche Technologie 
 
| Frontend: Flutter  Dart 
| Backend: Node.js
| Base de données: Firebase Firestore
| Authentification: Firebase Auth 
| Stockage médias: Cloudinary 

Fonctionnalités

- Authentification (inscription / connexion)
- Réservation de prestations beauté à domicile
- Gestion des spécialistes
- Catalogue de services par catégorie
- Upload et gestion des images via Cloudinary
- Notifications de réservation

Installation

Prérequis
- Flutter SDK
- Node.js
- Compte Firebase
- Compte Cloudinary

Étapes

1. Cloner le repo**
```bash
   git clone https://github.com/Matthew-bolia/BeautyHome.git
   cd BeautyHome
```

2. **Installer les dépendances Flutter**
```bash
   flutter pub get
```

3. **Installer les dépendances backend**
```bash
   cd functions
   npm install
```

4. **Configurer Firebase**
   - Créer un projet sur [Firebase Console](https://console.firebase.google.com)
   - Ajouter `google-services.json` dans `android/app/`
   - Ajouter `GoogleService-Info.plist` dans `ios/Runner/`
   - Configurer `firebase_options.dart`

5. **Configurer Cloudinary**
   - Créer un compte sur [Cloudinary](https://cloudinary.com)
   - Ajouter vos clés dans les variables d'environnement

6. **Lancer l'application**
```bash
   flutter run
```

---

## 👤 Auteur

**Matthieu Bolia**  
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=flat&logo=github&logoColor=white)](https://github.com/Matthew-bolia)

---

## 📄 Licence

Ce projet est sous licence MIT.
