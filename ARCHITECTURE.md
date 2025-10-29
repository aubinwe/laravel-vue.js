# 🏗️ Architecture Gestion de Notes

## Structure du projet
```
gestionNote/
├── appNotes/          # Backend Laravel (API)
├── frontend/          # Frontend Vue.js
├── database_schema.sql # Base de données MySQL
└── ARCHITECTURE.md    # Ce fichier
```

## 🔄 Flux de données
Frontend (Vue.js) ↔ API REST (Laravel) ↔ Base de données (MySQL)

## 🔐 Rôles et permissions
- **Étudiant**: Consulter ses notes, voir délibérations
- **Professeur**: Gérer notes de ses cours, réclamations
- **Administration**: Gestion complète, délibérations finales

## 🚀 Technologies
- **Frontend**: Vue.js 3, Pinia, Vue Router, Axios, Tailwind CSS
- **Backend**: Laravel 11, Sanctum, Eloquent ORM
- **Database**: MySQL 8.0