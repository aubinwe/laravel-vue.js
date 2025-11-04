@echo off
echo ========================================
echo   DEMARRAGE GESTION NOTES
echo ========================================

echo.
echo 1. Demarrage du serveur Laravel (Backend)...
cd /d "%~dp0appNotes"
start "Laravel Backend" cmd /k "php artisan serve --host=localhost --port=8000"

echo.
echo 2. Attente de 3 secondes...
timeout /t 3 /nobreak >nul

echo.
echo 3. Demarrage du serveur Vue.js (Frontend)...
cd /d "%~dp0frontend"
start "Vue Frontend" cmd /k "npm run dev"

echo.
echo ========================================
echo   SERVEURS DEMARRES !
echo ========================================
echo.
echo Backend:  http://localhost:8000
echo Frontend: http://localhost:5173
echo.
echo Comptes de test:
echo - Admin:     admin@gestion-notes.com / password
echo - Professeur: prof@test.com / password  
echo - Etudiant:   etudiant@test.com / password
echo.
echo Appuyez sur une touche pour fermer cette fenetre...
pause >nul