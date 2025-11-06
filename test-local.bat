@echo off
echo ========================================
echo   TEST LOCAL (SANS DOCKER)
echo ========================================

echo.
echo 1. Configuration du backend...
cd appNotes
copy .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed

echo.
echo 2. Demarrage du backend Laravel...
start "Backend Laravel" cmd /k "php artisan serve --host=0.0.0.0 --port=8000"

echo.
echo 3. Attente de 3 secondes...
timeout /t 3 /nobreak >nul

echo.
echo 4. Construction et demarrage du frontend...
cd ..\frontend
call npm install
call npm run build
start "Frontend Vue" cmd /k "npm run dev"

echo.
echo 5. Test de l'API...
timeout /t 5 /nobreak >nul
curl http://localhost:8000/api/health

echo.
echo ========================================
echo   ACCES A L'APPLICATION
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend API: http://localhost:8000/api
echo.
echo Comptes de test:
echo - admin@gestion-notes.com / password
echo - prof@test.com / password
echo - etudiant@test.com / password
echo.
pause