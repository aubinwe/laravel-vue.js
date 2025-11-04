# 🚀 Guide d'Utilisation - Gestion de Notes

## Démarrage Rapide

### 1. Démarrer l'application
```bash
# Double-cliquez sur ce fichier :
start-dev.bat
```

**IMPORTANT :** 
- 2 fenêtres vont s'ouvrir (Backend + Frontend)
- **NE FERMEZ PAS** ces fenêtres pendant l'utilisation
- Le Backend peut prendre quelques secondes à démarrer

### 2. Accéder à l'application
- **Application Web :** http://localhost:5173
- **API Backend :** http://localhost:8000

### 3. Comptes de test
| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Admin | admin@gestion-notes.com | password |
| Professeur | prof@test.com | password |
| Étudiant | etudiant@test.com | password |

## Scripts Utiles

### Démarrage
- `start-dev.bat` - Démarre les 2 serveurs
- `start-backend.bat` - Backend seulement
- `start-frontend.bat` - Frontend seulement

### Vérification
- `check-status.bat` - Vérifie que tout fonctionne
- `test-connection.bat` - Test complet de la configuration

## Résolution de Problèmes

### Le Backend ne démarre pas
1. Vérifiez que XAMPP est démarré
2. Vérifiez que MySQL fonctionne
3. Lancez : `start-backend.bat`

### Le Frontend ne démarre pas
1. Vérifiez que Node.js est installé
2. Lancez : `start-frontend.bat`

### Erreur de connexion
1. Vérifiez que les 2 serveurs sont démarrés
2. Lancez : `check-status.bat`

### Erreur de base de données
```bash
cd appNotes
php artisan migrate:fresh --seed
```

## URLs Importantes
- **Application :** http://localhost:5173
- **API :** http://localhost:8000/api
- **Santé API :** http://localhost:8000/api/health
- **PhpMyAdmin :** http://localhost/phpmyadmin

## Support
En cas de problème, vérifiez d'abord avec `check-status.bat`