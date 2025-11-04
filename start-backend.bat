@echo off
echo Demarrage du serveur Laravel...
cd /d "%~dp0appNotes"
php artisan serve --host=localhost --port=8000