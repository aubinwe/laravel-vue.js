@echo off
echo === CORRECTION CONNEXION MYSQL ===

echo 1. Demarrage XAMPP MySQL...
cd /d C:\xampp
start xampp-control.exe

echo 2. Attente 5 secondes...
timeout /t 5 /nobreak >nul

echo 3. Verification de la base de donnees...
cd /d C:\xampp\htdocs\gestionNote\appNotes

echo 4. Configuration .env...
echo DB_CONNECTION=mysql > .env.temp
echo DB_HOST=127.0.0.1 >> .env.temp
echo DB_PORT=3306 >> .env.temp
echo DB_DATABASE=gestion_notes >> .env.temp
echo DB_USERNAME=root >> .env.temp
echo DB_PASSWORD= >> .env.temp
echo APP_NAME="Gestion Notes" >> .env.temp
echo APP_ENV=local >> .env.temp
echo APP_KEY=base64:YourGeneratedKeyHere >> .env.temp
echo APP_DEBUG=true >> .env.temp
echo APP_URL=http://localhost:8000 >> .env.temp
echo SANCTUM_STATEFUL_DOMAINS=localhost:5173 >> .env.temp
echo SESSION_DRIVER=database >> .env.temp
echo CACHE_DRIVER=file >> .env.temp

copy .env.temp .env
del .env.temp

echo 5. Generation cle application...
php artisan key:generate

echo 6. Creation base de donnees...
php artisan migrate:fresh --seed

echo 7. Demarrage serveur...
start cmd /k "php artisan serve"

echo === MYSQL CORRIGE ===
pause