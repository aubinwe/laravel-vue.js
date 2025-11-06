@echo off
echo === CONNEXION RAPIDE ===

echo 1. Arret des services...
taskkill /f /im php.exe 2>nul
taskkill /f /im node.exe 2>nul

echo 2. Demarrage XAMPP...
cd /d C:\xampp
start xampp-control.exe

echo 3. Attente MySQL...
timeout /t 3 /nobreak >nul

echo 4. Backend Laravel...
cd /d C:\xampp\htdocs\gestionNote\appNotes
start cmd /k "php artisan serve --host=0.0.0.0 --port=8000"

echo 5. Attente backend...
timeout /t 3 /nobreak >nul

echo 6. Frontend Vue...
cd /d C:\xampp\htdocs\gestionNote\frontend
start cmd /k "npm run dev"

echo === SERVICES DEMARRES ===
echo Backend: http://localhost:8000
echo Frontend: http://localhost:5173
echo Admin: admin@gestion-notes.com / password
pause