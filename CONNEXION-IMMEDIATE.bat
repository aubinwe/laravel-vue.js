@echo off
echo === CONNEXION IMMEDIATE ===

echo 1. Arret XAMPP MySQL...
taskkill /f /im mysqld.exe 2>nul

echo 2. Demarrage conteneurs...
docker-compose up -d

echo 3. Attente 30 secondes...
timeout /t 30 /nobreak >nul

echo 4. Verification des services...
docker-compose ps

echo === APPLICATION PRETE ===
echo Frontend: http://localhost
echo Admin: admin@gestion-notes.com / password
echo Etudiant: etudiant@test.com / password
echo Professeur: prof@test.com / password

start http://localhost
pause