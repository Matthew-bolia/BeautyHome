 { pkgs, ... }: {
  # Utilise un canal stable pour garantir la compatibilité
  channel = "stable-24.05";

  # Liste des outils installés dans ton environnement cloud
  packages = [
    pkgs.jdk21
    pkgs.unzip
    pkgs.nodejs_20           # Indispensable pour Node.js et les outils Firebase
    pkgs.firebase-tools      # Pour l'émulateur et le déploiement Firebase
  ];

  # Variables d'environnement (vide pour l'instant)
  env = {};

  idx = {
    # Extensions VS Code pour booster ta productivité
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "Firebase.firebase-vscode"    # Interface graphique pour Firebase
      "christian-kohler.npm-intellisense" # Aide pour le code Node.js
      "esbenp.prettier-vscode"      # Pour formater proprement ton code
    ];

    workspace = {
      # Actions effectuées automatiquement à la création ou à l'ouverture
      onCreate = {
        # Télécharge les dépendances Flutter (pubspec.yaml)
        install-flutter-deps = "flutter pub get";
        
        # Installe les dépendances Node.js seulement si le dossier 'functions' existe
        install-node-deps = "if [ -d 'functions' ]; then cd functions && npm install; fi";
      };
      
      # Actions effectuées à chaque redémarrage de l'espace de travail
      onStart = {
        # Tu peux ajouter ici une commande pour lancer l'émulateur automatiquement
      };
    };

    # Configuration des aperçus (Émulateurs)
    previews = {
      enable = true;
      previews = {
        # Aperçu Web (Flutter Web)
        web = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "web-server"
            "--web-hostname"
            "0.0.0.0"
            "--web-port"
            "$PORT"
          ];
          manager = "flutter";
        };
        
        # Aperçu Android (Émulateur Cloud)
        android = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "android"
            "-d"
            "localhost:5555"
          ];
          manager = "flutter";
        };
      };
    };
  };
}