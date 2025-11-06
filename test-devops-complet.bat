@echo off
echo ========================================
echo    TEST COMPLET DEVOPS - GESTION NOTES
echo ========================================

echo.
echo [1/6] Verification des prerequis...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Docker n'est pas installe ou demarre
    exit /b 1
)

kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ERREUR: kubectl n'est pas installe
    exit /b 1
)

echo ✓ Docker et kubectl detectes

echo.
echo [2/6] Construction des images Docker...
docker-compose build --no-cache
if errorlevel 1 (
    echo ERREUR: Echec de construction des images
    exit /b 1
)
echo ✓ Images construites avec succes

echo.
echo [3/6] Test Docker Compose...
docker-compose up -d
timeout /t 30 >nul
docker-compose ps
echo ✓ Application demarree avec Docker Compose

echo.
echo [4/6] Nettoyage Docker Compose...
docker-compose down
echo ✓ Docker Compose arrete

echo.
echo [5/6] Demarrage Kubernetes...
minikube status >nul 2>&1
if errorlevel 1 (
    echo Demarrage de minikube...
    minikube start --driver=docker --memory=4096 --cpus=2
)

echo.
echo [6/6] Deploiement sur Kubernetes...
kubectl apply -f k8s/
echo ✓ Application deployee sur Kubernetes

echo.
echo Attente du demarrage des pods...
timeout /t 60 >nul

echo.
echo ========================================
echo           STATUT FINAL
echo ========================================
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

echo.
echo ========================================
echo         ACCES AUX SERVICES
echo ========================================
echo Frontend: kubectl port-forward -n gestion-notes service/frontend-service 8080:80
echo Backend:  kubectl port-forward -n gestion-notes service/backend-service 8000:8000
echo.
echo Puis acceder a: http://localhost:8080

pause