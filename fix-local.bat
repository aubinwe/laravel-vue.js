@echo off
echo === DIAGNOSTIC ET REPARATION LOCALE ===

echo 1. Verification des services XAMPP...
tasklist | findstr "httpd.exe" >nul && echo "Apache: OK" || echo "Apache: KO - Demarrer XAMPP"
tasklist | findstr "mysqld.exe" >nul && echo "MySQL: OK" || echo "MySQL: KO - Demarrer XAMPP"

echo.
echo 2. Test de connexion base de donnees...
cd appNotes
php -r "try { new PDO('mysql:host=127.0.0.1;dbname=gestion_notes', 'root', ''); echo 'DB: OK'; } catch(Exception $e) { echo 'DB: KO - ' . $e->getMessage(); }"

echo.
echo 3. Verification des dependances...
if not exist "vendor" (
    echo Installation des dependances...
    composer install
)

echo.
echo 4. Regeneration des caches...
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo.
echo 5. Recreation de la base...
php artisan migrate:fresh --seed

echo.
echo 6. Test du serveur...
echo Demarrage du serveur Laravel...
start /b php artisan serve
timeout /t 3
curl -s http://localhost:8000/api/health >nul && echo "API: OK" || echo "API: KO"

echo.
echo 7. Frontend...
cd ..\frontend
if not exist "node_modules" (
    echo Installation des dependances frontend...
    npm install
)

echo Demarrage du frontend...
start /b npm run dev

echo.
echo === ACCES ===
echo Frontend: http://localhost:5173
echo Backend: http://localhost:8000
pause