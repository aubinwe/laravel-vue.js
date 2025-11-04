@echo off
echo ========================================
echo   TEST DE CONNEXION
echo ========================================

echo.
echo 1. Test de la base de donnees...
cd /d "%~dp0appNotes"
php artisan tinker --execute="echo 'Utilisateurs: ' . App\Models\User::count(); echo 'Etudiants: ' . App\Models\Student::count(); echo 'Cours: ' . App\Models\Course::count();"

echo.
echo 2. Test de l'API...
php artisan route:list --path=api

echo.
echo 3. Configuration actuelle:
echo Backend URL: http://localhost:8000
echo Frontend URL: http://localhost:5173
echo API URL: http://localhost:8000/api

echo.
echo ========================================
echo   COMPTES DE TEST
echo ========================================
echo Admin:      admin@gestion-notes.com / password
echo Professeur: prof@test.com / password
echo Etudiant:   etudiant@test.com / password

echo.
echo Appuyez sur une touche pour continuer...
pause >nul