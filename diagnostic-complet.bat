@echo off
echo ========================================
echo    DIAGNOSTIC COMPLET DU PROJET
echo ========================================

echo.
echo === 1. VERIFICATION ENVIRONNEMENT ===
echo Verification PHP...
php --version | findstr "PHP" && echo [OK] PHP installe || echo [ERREUR] PHP non trouve

echo Verification Composer...
composer --version | findstr "Composer" && echo [OK] Composer installe || echo [ERREUR] Composer non trouve

echo Verification Node.js...
node --version && echo [OK] Node.js installe || echo [ERREUR] Node.js non trouve

echo Verification NPM...
npm --version && echo [OK] NPM installe || echo [ERREUR] NPM non trouve

echo.
echo === 2. VERIFICATION XAMPP ===
tasklist | findstr "httpd.exe" >nul && echo [OK] Apache demarre || echo [ERREUR] Apache arrete
tasklist | findstr "mysqld.exe" >nul && echo [OK] MySQL demarre || echo [ERREUR] MySQL arrete

echo.
echo === 3. TEST CONNEXION BASE DE DONNEES ===
echo Test connexion MySQL sans mot de passe...
php -r "try { new PDO('mysql:host=localhost', 'root', ''); echo '[OK] Connexion MySQL sans mot de passe\n'; } catch(Exception $e) { echo '[ERREUR] ' . $e->getMessage() . '\n'; }"

echo Test connexion MySQL avec mot de passe 'root'...
php -r "try { new PDO('mysql:host=localhost', 'root', 'root'); echo '[OK] Connexion MySQL avec mot de passe root\n'; } catch(Exception $e) { echo '[ERREUR] ' . $e->getMessage() . '\n'; }"

echo.
echo === 4. VERIFICATION BACKEND ===
cd appNotes

echo Verification fichier .env...
if exist ".env" (echo [OK] Fichier .env existe) else (echo [ERREUR] Fichier .env manquant)

echo Verification vendor...
if exist "vendor" (echo [OK] Dependances installees) else (echo [ERREUR] Lancer composer install)

echo Verification cle application...
php artisan key:generate --show | findstr "base64:" >nul && echo [OK] Cle application presente || echo [ERREUR] Cle application manquante

echo Test configuration Laravel...
php artisan config:clear >nul 2>&1
php artisan about | findstr "Environment" && echo [OK] Laravel configure || echo [ERREUR] Configuration Laravel

echo.
echo === 5. VERIFICATION BASE DE DONNEES ===
echo Creation base si necessaire...
php -r "try { $pdo = new PDO('mysql:host=localhost', 'root', ''); $pdo->exec('CREATE DATABASE IF NOT EXISTS gestion_notes'); echo '[OK] Base gestion_notes prete\n'; } catch(Exception $e) { echo '[ERREUR] ' . $e->getMessage() . '\n'; }"

echo Test connexion Laravel vers base...
php artisan tinker --execute="try { DB::connection()->getPdo(); echo '[OK] Laravel connecte a la base\n'; } catch(Exception \$e) { echo '[ERREUR] Laravel: ' . \$e->getMessage() . '\n'; }"

echo.
echo === 6. VERIFICATION MIGRATIONS ===
php artisan migrate:status 2>nul | findstr "Ran" >nul && echo [OK] Migrations executees || echo [INFO] Migrations a executer

echo.
echo === 7. VERIFICATION FRONTEND ===
cd ..\frontend

echo Verification package.json...
if exist "package.json" (echo [OK] package.json existe) else (echo [ERREUR] package.json manquant)

echo Verification node_modules...
if exist "node_modules" (echo [OK] Dependances frontend installees) else (echo [ERREUR] Lancer npm install)

echo Verification fichier .env frontend...
if exist ".env" (echo [OK] .env frontend existe) else (echo [ERREUR] .env frontend manquant)

echo.
echo === 8. TEST SERVEURS ===
cd ..\appNotes
echo Demarrage serveur Laravel...
start /b php artisan serve
timeout /t 3

echo Test serveur Laravel...
curl -s http://localhost:8000 >nul && echo [OK] Serveur Laravel accessible || echo [ERREUR] Serveur Laravel inaccessible

cd ..\frontend
echo Demarrage serveur Vue.js...
start /b npm run dev
timeout /t 5

echo Test serveur Vue.js...
curl -s http://localhost:5173 >nul && echo [OK] Serveur Vue.js accessible || echo [ERREUR] Serveur Vue.js inaccessible

echo.
echo ========================================
echo           RESUME DU DIAGNOSTIC
echo ========================================
echo Si tous les tests sont [OK], le projet devrait fonctionner
echo Sinon, corrigez les erreurs [ERREUR] une par une
echo.
pause