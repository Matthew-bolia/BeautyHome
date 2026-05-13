# ✅ Checklist Technique - Mise en Production

Date: 24 Avril 2026
Projet: Beauty Home - Services Management System v1.0

---

## 📦 Phase 1: Installation des Dépendances

- [ ] Exécuter `flutter pub get` 
  ```bash
  cd c:\Users\matthieu.bolia\Documents\BeautyHome
  flutter pub get
  ```

- [ ] Vérifier que `uuid: ^4.0.0` est bien dans pubspec.yaml
  ```bash
  grep "uuid" pubspec.yaml
  ```

- [ ] Compiler l'application sans erreurs
  ```bash
  flutter clean
  flutter pub get
  flutter analyze
  ```

---

## 🔧 Phase 2: Configuration Firestore

### 2.1 Collections

- [ ] Collection `salonServices` créée
  - Champ `categoryId` (string)
  - Champ `name` (string)
  - Champ `description` (string)
  - Champ `price` (number)
  - Champ `durationMinutes` (number)
  - Champ `images` (array)
  - Champ `createdAt` (timestamp)
  - Champ `isActive` (boolean)

- [ ] Collection `serviceCategories` créée avec les 12 catégories
  ```
  - haircut_women
  - haircut_men
  - haircut_children
  - manicure
  - pedicure
  - facial_care
  - massage
  - nail_art
  - eyebrow
  - waxing
  - extensions
  - makeup
  ```

### 2.2 Règles de Sécurité

- [ ] Règles Firestore appliquées (voir `FIRESTORE_SECURITY_RULES.txt`)
- [ ] Test: Client non-connecté peut lire les services actifs
- [ ] Test: Client non-admin ne peut pas créer
- [ ] Test: Admin peut créer/modifier/supprimer

### 2.3 Indices Firestore

- [ ] Indice créé pour `salonServices`:
  ```
  Collection: salonServices
  Champs: categoryId (Ascending), name (Ascending)
  ```

- [ ] Indice créé pour `salonServices`:
  ```
  Collection: salonServices
  Champs: isActive (Ascending), categoryId (Ascending)
  ```

---

## 👤 Phase 3: Utilisateur Admin

- [ ] Document utilisateur admin créé avec:
  ```json
  {
    "email": "admin@example.com",
    "name": "Admin",
    "isAdmin": true,
    "createdAt": timestamp,
    ...autres champs
  }
  ```

- [ ] Admin peut se connecter avec succès
- [ ] Admin voit le "Dashboard Administrateur" (pas un utilisateur normal)
- [ ] Admin peut accéder à "Services du Salon"

---

## 🎨 Phase 4: Test de l'Interface Admin

### 4.1 Accès au Dashboard

- [ ] Admin peut voir: `Dashboard Administrateur`
- [ ] Nouvelle tuile: "Services du Salon" (violet)
- [ ] Tuile cliquable et navigue vers le bon écran

### 4.2 Écran de Gestion des Services

- [ ] Les 12 catégories s'affichent en scroll horizontal
- [ ] Sélection d'une catégorie = surbrillance
- [ ] Aucun service affiché avant sélection
- [ ] FAB (+) désactivé avant sélection (optionnel)
- [ ] Message "Aucun service dans cette catégorie" approprié

### 4.3 Ajout d'un Service

#### Images
- [ ] Bouton "Galerie" fonctionnel
- [ ] Bouton "Caméra" fonctionnel
- [ ] Images sélectionnées affichées en GridView 2x2
- [ ] Bouton X supprime les images locales
- [ ] Peut ajouter plusieurs images
- [ ] Peut mixer galerie et caméra

#### Formulaire
- [ ] Champ "Nom du service" requis
- [ ] Champ "Description" requis
- [ ] Champ "Prix" accepte les nombres
- [ ] Champ "Durée" accepte les entiers
- [ ] Validation affichée si champs manquants
- [ ] Au moins une image requise

#### Enregistrement
- [ ] Clic "Enregistrer" = progression visuelle
- [ ] Upload des images vers Firebase
- [ ] Création du document dans Firestore
- [ ] Retour à la liste après succès
- [ ] Message de succès affiché
- [ ] Nouveau service visible dans la liste

### 4.4 Modification d'un Service

- [ ] Bouton Modifier charge le service existant
- [ ] Images existantes affichées séparément
- [ ] Peut ajouter de nouvelles images
- [ ] Peut supprimer des images existantes
- [ ] Données pré-remplies dans le formulaire
- [ ] Modification mise à jour correctement

### 4.5 Suppression d'un Service

- [ ] Bouton Supprimer affiche un dialogue de confirmation
- [ ] Confirmation supprime le service
- [ ] Service disparaît de la liste
- [ ] Message de succès affiché

---

## 📱 Phase 5: Test de l'Interface Client

### 5.1 Affichage des Services

- [ ] Page "Services" accessible
- [ ] Catégories affichées en scroll horizontal
- [ ] Aucun service avant sélection de catégorie (optionnel)
- [ ] Sélection d'une catégorie filtre les services
- [ ] Services s'affichent avec les informations correctes

### 5.2 Carrousel d'Images

- [ ] Images s'affichent en carrousel (PageView)
- [ ] Swipe dans le carrousel fonctionne
- [ ] Nombre d'images affiché
- [ ] Placeholder pendant le chargement
- [ ] Image en cache (CachedNetworkImage)

### 5.3 Informations du Service

- [ ] Nom du service correct
- [ ] Description complète visible
- [ ] Prix formaté correctement (€)
- [ ] Durée affichée (en minutes)
- [ ] Bouton "Réserver" présent et cliquable

### 5.4 Filtrage par Catégorie

- [ ] Sélection d'une catégorie filtre les services
- [ ] Plusieurs catégories testées
- [ ] Services corrects affichés par catégorie
- [ ] Désélection affiche tous les services

### 5.5 Services Inactifs

- [ ] Services avec `isActive: false` ne s'affichent pas aux clients
- [ ] Pas d'erreurs si zéro services actifs

---

## 🖼️ Phase 6: Test des Images

### 6.1 Upload d'Images

- [ ] Image de la galerie s'uploade
- [ ] Image de la caméra s'uploade
- [ ] URL Cloudinary/Firebase retournée
- [ ] Plusieurs images uploadées OK
- [ ] Taille de l'image compressée
- [ ] Pas de dépassement de quota Storage

### 6.2 Affichage des Images

- [ ] Images s'affichent correctement côté client
- [ ] Images cachées correctement
- [ ] Pas d'erreur CORS
- [ ] URLs expirées gérées (optionnel)

### 6.3 Suppression d'Images

- [ ] Suppression d'une image locale fonctionne
- [ ] Suppression d'une image existante fonctionne
- [ ] Document Firestore mis à jour
- [ ] Image pas réaffichée

---

## 🔒 Phase 7: Test de Sécurité

### 7.1 Contrôle d'Accès

- [ ] Client ne peut pas accéder à `manage_salon_services_screen`
- [ ] Client ne peut pas créer de services (API check)
- [ ] Client ne peut pas modifier de services (API check)
- [ ] Client ne peut pas supprimer de services (API check)
- [ ] Admin peut faire toutes les opérations

### 7.2 Règles Firestore

- [ ] Requête Firestore non-connecté pour services actifs: ✅
- [ ] Requête Firestore création par client: ❌
- [ ] Requête Firestore modification par client: ❌
- [ ] Requête Firestore suppression par client: ❌
- [ ] Requête Firestore création par admin: ✅

### 7.3 Injection & Validation

- [ ] Champs validés avant envoi
- [ ] Pas de injection de code
- [ ] XSS pas possible dans les descriptions
- [ ] Emojis dans les catégories affichés correctement

---

## 📊 Phase 8: Test de Performance

- [ ] Chargement de 50+ services: fluide
- [ ] Carrousel d'images: smooth
- [ ] Filtre par catégorie: rapide (< 1s)
- [ ] GridView d'images: pas de lag
- [ ] Pas de mémoire leak notable
- [ ] Images cachées correctement

---

## 🐛 Phase 9: Test des Cas Limites

### 9.1 Service sans image

- [ ] Message d'erreur "Veuillez ajouter une image"
- [ ] Service non créé
- [ ] Pas de plantage

### 9.2 Service avec 10+ images

- [ ] Upload de 10 images OK
- [ ] Carrousel affiche toutes les images
- [ ] Pas de dépassement de taille doc Firestore

### 9.3 Description très longue

- [ ] Description de 1000 caractères OK
- [ ] Affichage tronqué côté client (ellipsis)
- [ ] Pas d'overflow UI

### 9.4 Prix décimal

- [ ] Prix "35.50" OK
- [ ] Prix "35" OK
- [ ] Prix "35.99999" géré (2 décimales)
- [ ] Prix négatif: rejeté (validation)

### 9.5 Durée zéro

- [ ] Durée "0" validée (optionnel)
- [ ] Affichage "0 min" OK
- [ ] Pas de crash

### 9.6 Catégorie supprimée

- [ ] Services avec categoryId disparu: s'affichent toujours
- [ ] Pas d'erreur

---

## 📝 Phase 10: Documentation & Communication

- [ ] `SERVICES_MANAGEMENT_GUIDE.md` complet
- [ ] `FIRESTORE_SECURITY_RULES.txt` avec instructions
- [ ] `INITIALIZE_CATEGORIES.txt` avec 3 options
- [ ] `IMPLEMENTATION_SUMMARY.md` clair
- [ ] `ARCHITECTURE.md` détaillé
- [ ] Commentaires dans le code Dart

---

## 🚀 Phase 11: Déploiement

### 11.1 Avant la Production

- [ ] Tous les tests passent
- [ ] Pas d'erreurs Firestore dans les logs
- [ ] Pas d'erreurs Flutter dans les logs
- [ ] Performance acceptable
- [ ] Sécurité vérifiée

### 11.2 Migration Données (Optionnel)

- [ ] Services anciens migrés vers `salonServices` (si désiré)
- [ ] Images téléchargées pour les services anciens
- [ ] Catégories assignées correctement
- [ ] Pas de données perdues

### 11.3 Production

- [ ] Build release créé
  ```bash
  flutter build apk
  flutter build ios
  ```

- [ ] Publication sur les stores
- [ ] Monitoring logs en prod
- [ ] Plan de rollback prêt

---

## 📞 Phase 12: Support Post-Déploiement

- [ ] Admin formé à la gestion des services
- [ ] Client support documenté
- [ ] Processus de feedback établi
- [ ] Monitoring des erreurs (Firebase Crashlytics)
- [ ] Plan d'amélioration future

---

## 🎯 Signoff

| Élément | Responsable | Date | Approuvé |
|---------|-------------|------|----------|
| Code implementé | Dev | 24 Apr | ✓ |
| Tests fonctionnels | QA | | |
| Tests sécurité | DevOps | | |
| Données prod migrées | DBA | | |
| Admin formé | Support | | |
| Documentation | PM | | |
| Déploiement prod | DevOps | | |

---

## 📋 Notes Importantes

1. **Catégories**: Prédéfinies dans le code (pas de gestion admin)
2. **Images**: Uploadées vers Firebase Storage via Cloudinary
3. **Sécurité**: Règles Firestore strictes pour admin-only
4. **Performance**: Indices Firestore essentiels
5. **Migration**: Services anciens conservés pour compatibilité

---

## 🆘 Dépannage Rapide

| Problème | Solution |
|----------|----------|
| "pubspec.yaml" erreur | `flutter pub get` |
| Images ne s'uploadent pas | Vérifier permissions Storage & règles Firestore |
| Admin ne peut pas accéder | Vérifier `isAdmin: true` dans les données utilisateur |
| Services ne s'affichent pas | Vérifier `isActive: true` et catégories |
| Carrousel ne fonctionne pas | Vérifier PageView et CachedNetworkImage |
| Lenteur UI | Vérifier nombre d'images et indice Firestore |

---

**Créé: 24 Avril 2026**
**Version: 1.0**
**Statut: À implémenter**
