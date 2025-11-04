@echo off
echo ========================================
echo   DEMARRAGE GESTION NOTES
echo ========================================

echo.
echo INSTRUCTIONS:
echo 1. Ce script va ouvrir 2 fenetres separees
echo 2. Une pour le Backend (Laravel)
echo 3. Une pour le Frontend (Vue.js)
echo 4. NE FERMEZ PAS ces fenetres pendant l'utilisation
echo.
echo Appuyez sur une touche pour continuer...
pause >nul

echo.
echo Demarrage du Backend Laravel...
start "Backend Laravel - NE PAS FERMER" cmd /k "cd /d \"%~dp0\" && start-backend.bat"

echo Attente de 3 secondes...
ping 127.0.0.1 -n 4 >nul

echo.
echo Demarrage du Frontend Vue.js...
start "Frontend Vue.js - NE PAS FERMER" cmd /k "cd /d \"%~dp0\" && start-frontend.bat"

echo.
echo ========================================
echo   SERVEURS EN COURS DE DEMARRAGE
echo ========================================
echo.
echo URLs d'acces:
echo - Backend API: http://localhost:8000
echo - Application: http://localhost:5173
echo.
echo Comptes de test:
echo - Admin:      admin@gestion-notes.com / password
echo - Professeur: prof@test.com / password  
echo - Etudiant:   etudiant@test.com / password
echo.
echo IMPORTANT: Gardez les 2 fenetres ouvertes !
echo.
echo Appuyez sur une touche pour fermer cette fenetre...
pause >nul