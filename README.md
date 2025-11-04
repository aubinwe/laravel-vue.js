# 🎓 Gestion de Notes - Application Web

Application complète de gestion de notes universitaires avec Vue.js, Laravel et MySQL.

## 🚀 Installation Rapide

### Prérequis
- PHP 8.1+
- Composer
- Node.js 18+
- MySQL
- XAMPP (recommandé)

### Installation Automatique
```bash
# 1. Cloner le projet
git clone <votre-repo>
cd gestionNote

# 2. Exécuter l'installation (Windows)
install.bat

# 3. Démarrer l'application
start.bat
```

### Installation Manuelle

#### Backend (Laravel)
```bash
cd appNotes
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

#### Frontend (Vue.js)
```bash
cd frontend
npm install
npm run dev
```

## 🔐 Comptes de Test

- **Admin**: `admin@gestion-notes.com` / `password`
- **Professeur**: `prof@test.com` / `password`
- **Étudiant**: `etudiant@test.com` / `password`

## 🌐 URLs d'Accès

- **Application**: http://localhost:5173
- **API Backend**: http://localhost:8000
- **Base de données**: http://localhost/phpmyadmin

## 📋 Fonctionnalités

### 👨‍🎓 Étudiant
- Consulter ses notes
- Faire des réclamations
- Télécharger son bulletin
- Voir son profil

### 👨‍🏫 Professeur
- Ajouter/modifier des notes
- Faire des réclamations
- Traiter les réclamations
- Gérer ses cours

### 👨‍💼 Administration
- Ajouter des étudiants
- Gérer les cours
- Traiter toutes les réclamations
- Délibérations finales
- Statistiques complètes

## 🛠️ Technologies

- **Frontend**: Vue.js 3, Pinia, Vue Router, Tailwind CSS
- **Backend**: Laravel 11, Sanctum, Eloquent ORM
- **Base de données**: MySQL 8.0

## 📁 Structure du Projet

```
gestionNote/
├── appNotes/          # Backend Laravel
├── frontend/          # Frontend Vue.js
├── install.bat        # Script d'installation
├── start.bat          # Script de démarrage
└── README.md          # Documentation
```

## 🔧 Configuration

### Variables d'environnement

#### Backend (.env)
```env
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=
```

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:8000/api
```

## 🐛 Résolution de Problèmes

### Erreur PowerShell
```cmd
# Utiliser CMD au lieu de PowerShell
cd /d C:\xampp\htdocs\gestionNote
start.bat
```

### Erreur CORS
- Vérifier que les deux serveurs sont démarrés
- Backend: http://localhost:8000
- Frontend: http://localhost:5173

### Base de données
```bash
# Recréer la base
php artisan migrate:fresh --seed
```

## 📞 Support

Pour toute question ou problème, créer une issue sur GitHub.

## 📄 Licence

MIT License