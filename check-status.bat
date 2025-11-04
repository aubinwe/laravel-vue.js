@echo off
echo ========================================
echo   VERIFICATION DU STATUT
echo ========================================

echo.
echo 1. Test de connexion Backend (Laravel)...
curl -s http://localhost:8000/api/health >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Backend Laravel accessible sur http://localhost:8000
) else (
    echo [ERREUR] Backend Laravel non accessible
    echo Lancez: start-backend.bat
)

echo.
echo 2. Test de connexion Frontend (Vue.js)...
curl -s http://localhost:5173 >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Frontend Vue.js accessible sur http://localhost:5173
) else (
    echo [ERREUR] Frontend Vue.js non accessible
    echo Lancez: start-frontend.bat
)

echo.
echo 3. Test de la base de donnees...
cd /d "%~dp0appNotes"
php artisan tinker --execute="try { echo 'DB: OK - ' . App\Models\User::count() . ' utilisateurs'; } catch(Exception $e) { echo 'DB: ERREUR - ' . $e->getMessage(); }"

echo.
echo ========================================
echo   ACCES RAPIDE
echo ========================================
echo Application: http://localhost:5173
echo API Backend: http://localhost:8000/api
echo.
pause