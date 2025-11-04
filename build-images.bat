@echo off
echo === BUILD DES IMAGES DOCKER ===

echo 1. Build de l'image backend...
cd appNotes
docker build -t appnotes-backend:latest .
if %errorlevel% neq 0 (
    echo ERREUR: Build backend echoue
    pause
    exit /b 1
)

echo 2. Build de l'image frontend...
cd ..\frontend
docker build -t appnotes-frontend:latest .
if %errorlevel% neq 0 (
    echo ERREUR: Build frontend echoue
    pause
    exit /b 1
)

cd ..
echo === BUILD TERMINE ===
docker images | findstr appnotes
pause