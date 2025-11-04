@echo off
echo === DEPLOIEMENT KUBERNETES ===

echo 1. Suppression de l'ancien deploiement...
kubectl delete namespace gestion-notes --ignore-not-found=true
timeout /t 10

echo 2. Creation du namespace...
kubectl apply -f k8s\1-namespace.yaml

echo 3. Deploiement MySQL...
kubectl apply -f k8s\2-mysql.yaml
echo Attente du demarrage MySQL...
timeout /t 30

echo 4. Deploiement Backend...
kubectl apply -f k8s\3-backend.yaml
echo Attente du demarrage Backend...
timeout /t 20

echo 5. Deploiement Frontend...
kubectl apply -f k8s\4-frontend.yaml

echo 6. Verification du statut...
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

echo.
echo === ACCES A L'APPLICATION ===
echo Frontend: http://localhost:30000
echo Backend API: http://localhost:30001
echo.
echo Attendre que tous les pods soient RUNNING avant d'acceder
pause