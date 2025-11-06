@echo off
echo ========================================
echo   BUILD ET TEST COMPLET
echo ========================================

echo.
echo 1. Construction du frontend...
cd frontend
call npm install
call npm run build
cd ..

echo.
echo 2. Arret des conteneurs existants...
docker-compose down --remove-orphans
docker-compose -f docker-compose-fixed.yml down --remove-orphans

echo.
echo 3. Demarrage avec la version corrigee...
docker-compose -f docker-compose-fixed.yml up -d

echo.
echo 4. Attente du demarrage (60 secondes)...
timeout /t 60 /nobreak

echo.
echo 5. Test de l'API...
curl http://localhost:8000/api/health

echo.
echo 6. Verification des conteneurs...
docker-compose -f docker-compose-fixed.yml ps

echo.
echo 7. Logs du backend...
docker-compose -f docker-compose-fixed.yml logs backend

echo.
echo ========================================
echo   ACCES A L'APPLICATION
echo ========================================
echo.
echo Frontend: http://localhost
echo Backend API: http://localhost:8000/api
echo.
echo Comptes de test:
echo - admin@gestion-notes.com / password
echo - prof@test.com / password
echo - etudiant@test.com / password
echo.
pause