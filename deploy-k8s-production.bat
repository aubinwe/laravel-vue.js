@echo off
echo ========================================
echo    DEPLOIEMENT KUBERNETES PRODUCTION
echo ========================================

echo === ETAPE 1: NETTOYAGE ===
echo Suppression de l'ancien deploiement...
kubectl delete namespace gestion-notes --ignore-not-found=true
echo Attente de la suppression complete...
timeout /t 20

echo === ETAPE 2: BUILD DES IMAGES ===
echo Build de l'image backend...
cd appNotes
docker build -t appnotes-backend:latest .
if %errorlevel% neq 0 (
    echo ERREUR: Build backend echoue
    pause
    exit /b 1
)

echo Build de l'image frontend...
cd ..\frontend
docker build -t appnotes-frontend:latest .
if %errorlevel% neq 0 (
    echo ERREUR: Build frontend echoue
    pause
    exit /b 1
)

cd ..

echo === ETAPE 3: DEPLOIEMENT KUBERNETES ===
echo Application des manifests...
kubectl apply -f k8s-production\01-namespace.yaml
kubectl apply -f k8s-production\02-configmap.yaml
kubectl apply -f k8s-production\03-secret.yaml

echo Deploiement MySQL...
kubectl apply -f k8s-production\04-mysql.yaml
echo Attente du demarrage MySQL...
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s

echo Deploiement Backend...
kubectl apply -f k8s-production\05-backend.yaml
echo Attente du demarrage Backend...
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s

echo Deploiement Frontend...
kubectl apply -f k8s-production\06-frontend.yaml
echo Attente du demarrage Frontend...
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=180s

echo Configuration Ingress...
kubectl apply -f k8s-production\07-ingress.yaml

echo === ETAPE 4: VERIFICATION ===
echo Statut des pods:
kubectl get pods -n gestion-notes -o wide

echo Statut des services:
kubectl get services -n gestion-notes

echo Statut de l'ingress:
kubectl get ingress -n gestion-notes

echo === ETAPE 5: TESTS ===
echo Test de sante backend...
kubectl port-forward service/backend-service 8080:8000 -n gestion-notes &
timeout /t 5
curl -s http://localhost:8080/api/health && echo Backend: OK || echo Backend: KO
taskkill /f /im kubectl.exe >nul 2>&1

echo.
echo ========================================
echo         DEPLOIEMENT TERMINE !
echo ========================================
echo.
echo ACCES A L'APPLICATION:
echo - Via NodePort: http://localhost:30080
echo - Via Ingress: http://votre-cluster-ip
echo.
echo IDENTIFIANTS:
echo - Admin: admin@gestion-notes.com / password
echo - Professeur: prof@test.com / password
echo - Etudiant: etudiant@test.com / password
echo.
echo COMMANDES UTILES:
echo - Logs backend: kubectl logs -f deployment/backend -n gestion-notes
echo - Logs frontend: kubectl logs -f deployment/frontend -n gestion-notes
echo - Logs MySQL: kubectl logs -f deployment/mysql -n gestion-notes
echo - Shell backend: kubectl exec -it deployment/backend -n gestion-notes -- /bin/sh
echo.

pause