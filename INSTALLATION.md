# 🚀 Installation - Gestion des Notes

## 📋 Prérequis
- PHP 8.1+
- Composer
- Node.js 16+
- MySQL 8.0+
- XAMPP ou serveur local

## 🔧 Installation Backend (Laravel)

```bash
cd appNotes

# Installation des dépendances
composer install

# Configuration
cp .env.example .env
php artisan key:generate

# Base de données
mysql -u root -p < ../database_schema.sql

# Migrations (optionnel si vous utilisez le SQL)
php artisan migrate

# Démarrage du serveur
php artisan serve
```

## 🎨 Installation Frontend (Vue.js)

```bash
cd frontend

# Installation des dépendances
npm install

# Démarrage du serveur de développement
npm run dev
```

## 🔐 Comptes de test

- **Admin**: admin@test.com / password
- **Professeur**: prof@test.com / password  
- **Étudiant**: etudiant@test.com / password

## 📡 Endpoints API

### Authentification
- `POST /api/login` - Connexion
- `POST /api/logout` - Déconnexion
- `GET /api/me` - Profil utilisateur

### Notes (protégé)
- `GET /api/grades` - Liste des notes
- `POST /api/grades` - Créer une note
- `PUT /api/grades/{id}` - Modifier une note
- `DELETE /api/grades/{id}` - Supprimer une note

### Réclamations (protégé)
- `GET /api/claims` - Liste des réclamations
- `POST /api/claims` - Créer une réclamation
- `PUT /api/claims/{id}` - Modifier le statut

## 🏗️ Architecture

```
gestionNote/
├── appNotes/          # Backend Laravel
│   ├── app/Models/    # Modèles Eloquent
│   ├── app/Http/Controllers/ # Contrôleurs API
│   └── routes/api.php # Routes API
├── frontend/          # Frontend Vue.js
│   ├── src/stores/    # Stores Pinia
│   ├── src/views/     # Pages Vue
│   └── src/lib/       # Configuration API
└── database_schema.sql # Structure BDD
```