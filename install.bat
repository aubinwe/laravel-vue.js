@echo off
echo ========================================
echo    INSTALLATION GESTION NOTES
echo ========================================

echo.
echo 1. Installation des dependances Laravel...
cd appNotes
composer install
php artisan key:generate

echo.
echo 2. Configuration de la base de donnees...
php artisan migrate:fresh --seed

echo.
echo 3. Installation des dependances Vue.js...
cd ..\frontend
npm install

echo.
echo ========================================
echo    INSTALLATION TERMINEE !
echo ========================================
echo.
echo Pour demarrer l'application, executez: start.bat
echo.
pause