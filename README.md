# 🏡 Real Estate Mobile Application

Une application mobile moderne de gestion immobilière développée avec Flutter et Node.js, permettant aux utilisateurs de rechercher, publier et gérer des propriétés.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)
![MongoDB](https://img.shields.io/badge/MongoDB-6.x-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 📱 Captures d'écran
<table> <tr> <td><img src="https://github.com/user-attachments/assets/2e8785bd-d40e-432a-a11d-c33f84b60a3f" width="220"></td> <td><img src="https://github.com/user-attachments/assets/43a03b76-7e71-4c96-86ca-dc70babdbc49" width="220"></td> <td><img src="https://github.com/user-attachments/assets/320ff7f9-d7b0-415d-9133-cd695c128727" width="220"></td> </tr> <tr> <td><img src="https://github.com/user-attachments/assets/feac5a4a-f4a7-4a61-a168-ec6bebd57f5d" width="220"></td> <td><img src="https://github.com/user-attachments/assets/8a7c84a1-fcbd-4597-b063-61c6dace85b6" width="220"></td> <td><img src="https://github.com/user-attachments/assets/4f9a97ab-70f1-45e2-b224-a22b0333b6e2" width="220"></td> </tr> <tr> <td><img src="https://github.com/user-attachments/assets/5b4a52f4-8688-49bf-bb7d-02650e44665f" width="220"></td> <td><img src="https://github.com/user-attachments/assets/106a1ca5-9855-4712-8aca-fd5f77a8e17d" width="220"></td> <td><img src="https://github.com/user-attachments/assets/c01f1222-68d0-4e1e-b081-8a07ff6c3d19" width="220"></td> </tr> </table>

### 🔐 Authentification & Profil
- ✅ Inscription et connexion sécurisées
- ✅ Authentification sociale (Google)
- ✅ Réinitialisation de mot de passe avec code de vérification
- ✅ Gestion complète du profil utilisateur
- ✅ Upload de photo de profil

### 🏠 Gestion des Propriétés
- ✅ Recherche avancée avec filtres (ville, type, prix, superficie)
- ✅ Affichage sur carte interactive (Flutter Map)
- ✅ Liste détaillée avec images et informations
- ✅ Ajout et modification de propriétés
- ✅ 21 propriétés pré-chargées (Maroc + Tunisie)
- ✅ Coordonnées GPS réelles pour chaque propriété

### 📍 Localisation
- ✅ **Maroc** : Casablanca, Marrakech, Rabat, Fès, Tanger, Agadir
- ✅ **Tunisie** : Tunis, La Marsa, Sousse, Hammamet, Sfax, Monastir, Nabeul, Tozeur, Gafsa

### 🎨 Interface Utilisateur
- ✅ Design moderne Material Design 3
- ✅ Gradient indigo/purple (#6366F1 → #8B5CF6)
- ✅ Landing page avec images immersives
- ✅ Navigation fluide avec animations
- ✅ Thème cohérent sur toutes les pages
- ✅ Support responsive

### 💬 Fonctionnalités Sociales
- ✅ Système de favoris
- ✅ Messagerie intégrée
- ✅ Avis et évaluations (reviews)
- ✅ Partage de propriétés
- ✅ Recherches sauvegardées

### 📊 Analytics
- ✅ Statistiques de vues
- ✅ Historique de recherche
- ✅ Favoris tracking

## 🛠️ Technologies Utilisées

### Frontend (Mobile App)
- **Framework** : Flutter 3.x
- **Language** : Dart
- **State Management** : Provider
- **Cartographie** : Flutter Map 7.0.2
- **HTTP Client** : http package
- **UI/UX** : Material Design 3, Google Fonts (Poppins)

### Backend (API)
- **Runtime** : Node.js 18.x
- **Framework** : Express.js
- **Base de données** : MongoDB 6.x
- **ODM** : Mongoose
- **Authentification** : JWT (jsonwebtoken)
- **Upload** : Multer
- **Validation** : express-validator

## 📁 Structure du Projet

```
projet-f/
├── mobile_app/                 # Application Flutter
│   ├── lib/
│   │   ├── models/            # Modèles de données
│   │   ├── providers/         # State management (Provider)
│   │   ├── screens/           # Écrans de l'application
│   │   │   ├── auth/         # Authentification
│   │   │   ├── home/         # Accueil & navigation
│   │   │   ├── property/     # Propriétés
│   │   │   ├── map/          # Carte interactive
│   │   │   ├── search/       # Recherche
│   │   │   ├── profile/      # Profil utilisateur
│   │   │   └── onboarding/   # Landing page
│   │   ├── services/         # Services API
│   │   ├── utils/            # Utilitaires
│   │   └── widgets/          # Composants réutilisables
│   └── pubspec.yaml
│
├── backend/                   # API Node.js
│   ├── models/               # Modèles MongoDB
│   │   ├── User.js
│   │   ├── Property.js
│   │   ├── Review.js
│   │   └── Message.js
│   ├── routes/               # Routes API
│   ├── middleware/           # Middleware (auth, upload)
│   ├── config/               # Configuration
│   ├── seed.js               # Données initiales
│   └── server.js
│
└── README.md
```

## 🚀 Installation

### Prérequis
- Flutter SDK 3.x ou supérieur
- Node.js 18.x ou supérieur
- MongoDB 6.x ou supérieur
- Android Studio / Xcode (pour émulateurs)

### Backend Setup

1. **Installer les dépendances**
```bash
cd backend
npm install
```

2. **Configuration de l'environnement**
Créer un fichier `.env` :
```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/real_estate
JWT_SECRET=votre_secret_jwt_super_securise
```

3. **Lancer MongoDB**
```bash
mongod
```

4. **Charger les données initiales**
```bash
node seed.js
```

5. **Démarrer le serveur**
```bash
npm start
```

Le serveur sera accessible sur `http://localhost:5000`

### Frontend Setup

1. **Installer Flutter**
Suivre les instructions sur [flutter.dev](https://flutter.dev/docs/get-started/install)

2. **Installer les dépendances**
```bash
cd mobile_app
flutter pub get
```

3. **Configuration de l'API**
Modifier `lib/utils/api_constants.dart` :
```dart
static const String baseUrl = 'http://VOTRE_IP:5000/api';
```

4. **Lancer l'application**
```bash
flutter run
```

## 📡 API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/social-login` - Connexion sociale
- `POST /api/auth/request-password-reset` - Demande de réinitialisation
- `POST /api/auth/reset-password` - Réinitialisation mot de passe

### Propriétés
- `GET /api/properties` - Liste des propriétés (avec filtres et pagination)
- `GET /api/properties/:id` - Détails d'une propriété
- `POST /api/properties` - Créer une propriété (auth requise)
- `PUT /api/properties/:id` - Modifier une propriété (auth requise)
- `DELETE /api/properties/:id` - Supprimer une propriété (auth requise)

### Utilisateur
- `GET /api/users/me` - Profil utilisateur
- `PUT /api/users/profile` - Modifier le profil
- `POST /api/users/upload-photo` - Upload photo de profil

### Favoris
- `GET /api/favorites` - Liste des favoris
- `POST /api/favorites/:propertyId` - Ajouter un favori
- `DELETE /api/favorites/:propertyId` - Retirer un favori

### Avis
- `GET /api/properties/:id/reviews` - Avis d'une propriété
- `POST /api/properties/:id/reviews` - Ajouter un avis

### Messages
- `GET /api/messages` - Liste des conversations
- `POST /api/messages` - Envoyer un message

## 🎨 Design System

### Couleurs Principales
- **Primary (Indigo)** : `#6366F1`
- **Secondary (Purple)** : `#8B5CF6`
- **Accent (Pink)** : `#EC4899`
- **Background** : `#F8F9FE`
- **Text** : `#1F2937`

### Typography
- **Font Family** : Poppins (Google Fonts)
- **Weights** : Regular (400), Medium (500), SemiBold (600), Bold (700)

### Gradient
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
  ],
)
```

## 📊 Données Pré-chargées

L'application contient **21 propriétés** réparties entre le Maroc et la Tunisie :

### Maroc (10 propriétés)
- **Casablanca** : 3 propriétés (Villa, Appartement, Penthouse)
- **Marrakech** : 2 propriétés (Riad, Villa)
- **Rabat** : 2 propriétés (Appartement, Villa)
- **Fès** : 1 propriété (Maison)
- **Tanger** : 1 propriété (Appartement)
- **Agadir** : 1 propriété (Villa)

### Tunisie (11 propriétés)
- **Tunis** : 2 propriétés (Appartement, Villa)
- **La Marsa** : 1 propriété (Villa)
- **Sousse** : 1 propriété (Appartement)
- **Hammamet** : 1 propriété (Villa)
- **Sfax** : 1 propriété (Maison)
- **Monastir** : 1 propriété (Villa)
- **Nabeul** : 1 propriété (Appartement)
- **Tozeur** : 2 propriétés (Villa, Maison)
- **Gafsa** : 1 propriété (Villa)

Toutes les propriétés ont des coordonnées GPS réelles et s'affichent correctement sur la carte.

## 🔧 Configuration Réseau

Pour tester l'application sur un appareil physique :

1. **Trouver votre IP locale**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

2. **Mettre à jour l'API URL**
Dans `mobile_app/lib/utils/api_constants.dart` :
```dart
static const String baseUrl = 'http://VOTRE_IP:5000/api';
```

3. **S'assurer que le firewall autorise le port 5000**

## 🧪 Tests

### Backend
```bash
cd backend
npm test
```

### Frontend
```bash
cd mobile_app
flutter test
```

## 🐛 Problèmes Connus & Solutions

### La carte n'affiche pas toutes les propriétés
✅ **Solution** : Utilise `fetchAllProperties()` avec `limit: 1000` dans `map_screen.dart`

### Les propriétés tunisiennes ne s'affichent pas
✅ **Solution** : Coordonnées GPS réelles ajoutées pour toutes les villes tunisiennes

### Erreur de connexion API
✅ **Solution** : Vérifier l'IP locale et s'assurer que le backend est démarré

## 📝 TODO / Améliorations Futures

- [ ] Mode sombre
- [ ] Notifications push
- [ ] Chat en temps réel avec Socket.io
- [ ] Filtres avancés supplémentaires
- [ ] Export PDF des propriétés
- [ ] Système de réservation/visite
- [ ] Multi-langue (FR/AR/EN)
- [ ] Tests automatisés complets
- [ ] CI/CD avec GitHub Actions

## 👥 Contributeurs

- **Développeur Principal** : Real Estate Mobile Collaboration Team
- **Design UI/UX** : Material Design 3
- **Backend** : Node.js/Express
- **Mobile** : Flutter

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- Flutter Team pour le framework incroyable
- Node.js & Express.js community
- MongoDB Team
- Unsplash pour les images de haute qualité
- Google Fonts pour la typographie Poppins

## 📞 Contact

Pour toute question ou suggestion :
- GitHub : https://github.com/Real-Estate-Mobile-Collaboration

---

**Développé avec ❤️ en utilisant Flutter & Node.js**
