@echo off
echo ========================================
echo    DEMARRAGE GESTION NOTES
echo ========================================

echo.
echo 1. Demarrage du serveur Laravel...
cd appNotes
start "Laravel Server" cmd /k "php artisan serve"

echo.
echo 2. Attente de 3 secondes...
timeout /t 3 /nobreak > nul

echo.
echo 3. Demarrage du serveur Vue.js...
cd ..\frontend
start "Vue.js Server" cmd /k "npm run dev"

echo.
echo ========================================
echo    SERVEURS DEMARRES !
echo ========================================
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:8000
echo.
echo Appuyez sur une touche pour fermer...
pause > nul