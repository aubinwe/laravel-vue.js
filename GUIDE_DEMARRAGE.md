# 🚀 Guide de Démarrage - Gestion de Notes

## 📋 Prérequis
- PHP 8.1+
- Composer
- Node.js 18+
- MySQL 8.0
- XAMPP (ou équivalent)

## 🗄️ 1. Configuration Base de Données
```bash
# Démarrer MySQL via XAMPP
# Importer le fichier database_schema.sql dans phpMyAdmin
# Ou via ligne de commande :
mysql -u root -p < database_schema.sql
```

## 🔧 2. Configuration Backend (Laravel)
```bash
cd appNotes

# Installer les dépendances
composer install

# Générer la clé d'application
php artisan key:generate

# Configurer la base de données dans .env
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=

# Démarrer le serveur
php artisan serve
```

## 🎨 3. Configuration Frontend (Vue.js)
```bash
cd frontend

# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm run dev
```

## 🔐 4. Comptes de Test
- **Admin**: admin@gestion-notes.com / password
- **Professeur**: prof@test.com / password  
- **Étudiant**: etudiant@test.com / password

## 📡 5. Endpoints API Principaux

### Authentification
- `POST /api/login` - Connexion
- `POST /api/logout` - Déconnexion
- `GET /api/me` - Profil utilisateur

### Notes
- `GET /api/grades` - Liste des notes
- `POST /api/grades` - Créer une note
- `PUT /api/grades/{id}` - Modifier une note
- `DELETE /api/grades/{id}` - Supprimer une note

### Réclamations
- `GET /api/claims` - Liste des réclamations
- `POST /api/claims` - Créer une réclamation
- `PUT /api/claims/{id}` - Modifier le statut

## 🌐 URLs d'accès
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8000/api
- **Base de données**: http://localhost/phpmyadmin

## 🔄 Workflow de développement
1. Démarrer XAMPP (Apache + MySQL)
2. Lancer le backend Laravel: `php artisan serve`
3. Lancer le frontend Vue.js: `npm run dev`
4. Accéder à l'application via http://localhost:5173