@echo off
echo === DEMARRAGE RAPIDE ===

echo 1. Backend...
cd appNotes
start /b php artisan serve
echo Backend demarre sur http://localhost:8000

echo 2. Frontend...
cd ..\frontend  
start /b npm run dev
echo Frontend demarre sur http://localhost:5173

echo.
echo === COMPTES DE TEST ===
echo Admin: admin@gestion-notes.com / password
echo Professeur: prof@test.com / password
echo Etudiant: etudiant@test.com / password

timeout /t 5
start http://localhost:5173