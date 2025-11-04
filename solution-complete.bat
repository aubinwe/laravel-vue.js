@echo off
echo ========================================
echo      SOLUTION COMPLETE DU PROJET
echo ========================================

echo === ETAPE 1: PREPARATION ===
echo Arret des serveurs existants...
taskkill /f /im php.exe >nul 2>&1
taskkill /f /im node.exe >nul 2>&1

echo === ETAPE 2: BACKEND ===
cd appNotes

echo Installation dependances backend...
composer install --no-dev

echo Configuration Laravel...
copy .env.example .env >nul 2>&1
php artisan key:generate

echo Nettoyage cache...
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo Creation base de donnees...
php -r "try { \$pdo = new PDO('mysql:host=localhost', 'root', ''); \$pdo->exec('DROP DATABASE IF EXISTS gestion_notes; CREATE DATABASE gestion_notes'); echo 'Base creee\n'; } catch(Exception \$e) { echo 'Erreur: ' . \$e->getMessage() . '\n'; }"

echo Migrations et seeders...
php artisan migrate:fresh --seed

echo Demarrage serveur Laravel...
start /b php artisan serve
timeout /t 3

echo === ETAPE 3: FRONTEND ===
cd ..\frontend

echo Installation dependances frontend...
npm install

echo Configuration frontend...
echo VITE_API_URL=http://localhost:8000/api > .env

echo Demarrage serveur Vue.js...
start /b npm run dev
timeout /t 5

echo === ETAPE 4: VERIFICATION ===
echo Test serveur Laravel...
curl -s http://localhost:8000 >nul && echo [OK] Laravel accessible || echo [ERREUR] Laravel inaccessible

echo Test serveur Vue.js...
curl -s http://localhost:5173 >nul && echo [OK] Vue.js accessible || echo [ERREUR] Vue.js inaccessible

echo Test API login...
curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d "{\"email\":\"admin@gestion-notes.com\",\"password\":\"password\"}" -s | findstr "token" >nul && echo [OK] Login fonctionne || echo [ERREUR] Login ne fonctionne pas

echo.
echo ========================================
echo            PROJET PRET !
echo ========================================
echo.
echo ACCES:
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:8000
echo.
echo IDENTIFIANTS:
echo Admin:      admin@gestion-notes.com / password
echo Professeur: prof@test.com / password
echo Etudiant:   etudiant@test.com / password
echo.
echo Ouvrir le navigateur...
start http://localhost:5173

pause