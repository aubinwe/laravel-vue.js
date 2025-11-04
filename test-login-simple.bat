@echo off
echo === TEST CONNEXION SIMPLE ===

cd appNotes

echo 1. Nettoyage complet...
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo 2. Test serveur sans base...
start /b php artisan serve
timeout /t 3

echo 3. Test page d'accueil...
curl -s http://localhost:8000 >nul && echo "Serveur Laravel: OK" || echo "Serveur Laravel: KO"

echo 4. Maintenant test avec base...
php artisan migrate:fresh --seed

echo 5. Test API login...
curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d "{\"email\":\"admin@gestion-notes.com\",\"password\":\"password\"}" && echo "Login API: OK" || echo "Login API: KO"

echo.
echo === ACCES ===
echo Backend: http://localhost:8000
echo Identifiants: admin@gestion-notes.com / password

pause