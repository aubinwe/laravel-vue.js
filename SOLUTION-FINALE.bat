@echo off
echo === SOLUTION FINALE - CONNEXION GARANTIE ===

echo 1. Demarrage XAMPP...
cd /d C:\xampp
start xampp-control.exe

echo 2. Attente 5 secondes...
timeout /t 5 /nobreak >nul

echo 3. Configuration backend...
cd /d C:\xampp\htdocs\gestionNote\appNotes

echo DB_CONNECTION=mysql > .env
echo DB_HOST=127.0.0.1 >> .env
echo DB_PORT=3306 >> .env
echo DB_DATABASE=gestion_notes >> .env
echo DB_USERNAME=root >> .env
echo DB_PASSWORD= >> .env
echo APP_NAME="Gestion Notes" >> .env
echo APP_ENV=local >> .env
echo APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= >> .env
echo APP_DEBUG=true >> .env
echo APP_URL=http://localhost:8000 >> .env
echo SANCTUM_STATEFUL_DOMAINS=localhost:5173 >> .env
echo SESSION_DRIVER=database >> .env
echo CACHE_DRIVER=file >> .env

echo 4. Creation base de donnees...
php artisan migrate:fresh --seed --force

echo 5. Demarrage backend...
start cmd /k "php artisan serve --host=0.0.0.0 --port=8000"

echo 6. Configuration frontend...
cd /d C:\xampp\htdocs\gestionNote\frontend
echo VITE_API_URL=http://localhost:8000/api > .env

echo 7. Demarrage frontend...
start cmd /k "npm run dev"

echo === APPLICATION DEMARREE ===
echo Frontend: http://localhost:5173
echo Backend: http://localhost:8000
echo 
echo COMPTES DE TEST:
echo Admin: admin@gestion-notes.com / password
echo Etudiant: etudiant@test.com / password  
echo Professeur: prof@test.com / password

timeout /t 5 /nobreak >nul
start http://localhost:5173
pause