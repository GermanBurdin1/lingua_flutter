# 🌌 Lang App - Flutter (Design Cosmique)

Application mobile d'apprentissage des langues avec design cosmique néon et commande vocale.

## ✨ Fonctionnalités

- 🎨 **Design Cosmique Néon** - Interface futuriste avec effets spatiaux
- 🌓 **Mode Sombre/Clair** - Basculement entre thèmes cosmiques
- 🎤 **Commande Vocale** - Enregistrement et reconnaissance vocale (via Groq API)
- 📚 **Gestion du Vocabulaire** - Ajout, affichage et gestion des mots
- 🇫🇷 **Interface en Français** - Entièrement traduite
- 🚀 **Animations Fluides** - Transitions et effets visuels

## 🛠 Installation

### Prérequis

- Flutter SDK 3.35.6+
- Dart 3.9.2+

### Installation de Flutter (Windows)

1. Téléchargez Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extrayez dans `C:\flutter`
3. Ajoutez `C:\flutter\bin` à la variable PATH
4. Vérifiez l'installation:
```bash
flutter doctor
```

### Installation des dépendances

```bash
cd mobile_app_flutter
flutter pub get
```

## ⚙️ Configuration

### 1. API Backend

Ouvrez `lib/services/api_service.dart` et configurez l'URL:

```dart
static const String baseUrl = 'http://localhost:3000';
```

**Pour émulateur Android:** utilisez `http://10.0.2.2:3000`  
**Pour appareil physique:** utilisez votre IP locale (ex: `http://192.168.1.100:3000`)

### 2. Token JWT (temporaire)

Pour l'instant, l'app nécessite un token JWT du backend:

1. Connectez-vous à l'application Angular
2. Ouvrez DevTools (F12) → Application → Local Storage
3. Copiez le `access_token`
4. Dans `lib/providers/vocabulary_provider.dart`, décommentez et ajoutez le token:

```dart
_apiService.setToken('VOTRE_TOKEN_ICI');
```

## 🚀 Lancement

### Web (Chrome)

```bash
flutter run -d chrome
```

### Android

```bash
flutter run
```

### iOS (nécessite macOS)

```bash
flutter run -d ios
```

## 🎨 Thèmes

L'application propose 2 thèmes cosmiques:

### Thème Sombre (par défaut)
- Fond: Noir spatial (#0A0E27)
- Primaire: Cyan néon (#00F5FF)
- Secondaire: Magenta néon (#FF00FF)
- Tertiaire: Vert néon (#00FF88)
- Étoiles animées et effets de lumière

### Thème Clair
- Fond: Blanc céleste (#F0F4FF)
- Primaire: Bleu cosmique (#0066FF)
- Secondaire: Violet (#7C4DFF)
- Tertiaire: Vert (#00C853)
- Étoiles subtiles et effets doux

**Basculement:** Cliquez sur l'icône 🌙/☀️ dans l'AppBar

## 🎤 Commande Vocale

### Configuration Backend

Le backend doit avoir la clé GROQ_API_KEY dans le fichier `.env`:

```env
GROQ_API_KEY=votre_clé_groq
```

Obtenez une clé gratuite: https://console.groq.com/keys

### Utilisation

1. Dans l'écran Vocabulaire, activez la commande vocale
2. Maintenez le bouton d'enregistrement
3. Prononcez un mot en français
4. Le mot sera reconnu automatiquement via Groq Whisper
5. Confirmez pour l'ajouter au vocabulaire

## 📱 Structure du Projet

```
lib/
├── main.dart                     # Point d'entrée
├── models/                       # Modèles de données
│   └── word.dart
├── providers/                    # State management
│   ├── auth_provider.dart
│   ├── vocabulary_provider.dart
│   └── theme_provider.dart       # ⭐ Gestion des thèmes
├── screens/                      # Écrans
│   ├── main_screen.dart          # Écran principal
│   ├── vocabulary_screen.dart    # Vocabulaire
│   └── word_detail_screen.dart   # Détails du mot
├── services/                     # Services API
│   └── api_service.dart
└── widgets/                      # Widgets réutilisables
    ├── voice_recorder.dart       # Enregistrement vocal
    └── cosmic_background.dart    # ⭐ Fond cosmique
```

## 🎯 À Faire

- [ ] Authentification complète
- [ ] Écran des traductions
- [ ] Écran de grammaire
- [ ] Profil utilisateur
- [ ] Mode hors ligne
- [ ] Statistiques d'apprentissage
- [ ] Notifications de révision

## 🐛 Dépannage

### Commande vocale ne fonctionne pas

1. Vérifiez que le backend est lancé sur le port 3000
2. Vérifiez que GROQ_API_KEY est configuré
3. Vérifiez les permissions microphone sur l'appareil

### Erreur de connexion API

1. Vérifiez l'URL dans `api_service.dart`
2. Pour émulateur: utilisez `http://10.0.2.2:3000`
3. Pour appareil: utilisez votre IP locale
4. Vérifiez que le firewall autorise le port 3000

### Flutter non reconnu (PowerShell)

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

Ou utilisez le script de lancement:
```powershell
.\run.ps1
```

## 🏗️ Build de Production

### Android APK

```bash
flutter build apk --release
```

Le fichier APK sera dans: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

## 📄 Licence

MIT

## 🌟 Caractéristiques Visuelles

- ✨ Fond spatial animé avec étoiles
- 🌈 Gradients néon sur tous les boutons
- 💫 Effets de lumière et ombres colorées
- 🎭 Transitions fluides entre thèmes
- 🔮 Cartes translucides avec bordures lumineuses
- ⚡ Animations de pulsation pour l'enregistrement vocal
