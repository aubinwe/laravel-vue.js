@echo off
echo ========================================
echo   TEST CONTENEURISATION DOCKER
echo ========================================

echo.
echo 1. Construction des images Docker...
docker-compose build

echo.
echo 2. Demarrage des conteneurs...
docker-compose up -d

echo.
echo 3. Verification du statut...
docker-compose ps

echo.
echo 4. Test de l'application...
timeout /t 10 /nobreak >nul
echo Testing API health...
curl -f http://localhost:8000/api/health

echo.
echo 5. URLs d'acces:
echo - Application: http://localhost
echo - API: http://localhost:8000/api
echo - Base de donnees: localhost:3306

echo.
echo Pour arreter: docker-compose down
pause