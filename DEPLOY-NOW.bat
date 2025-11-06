@echo off
echo === DEPLOIEMENT IMMEDIAT ===

echo Attente Docker Desktop...
timeout /t 30 /nobreak >nul

echo Demarrage application...
docker-compose up -d

echo Verification...
docker-compose ps

echo === APPLICATION DEPLOYEE ===
echo URL: http://localhost
echo Admin: admin@gestion-notes.com / password

start http://localhost
pause