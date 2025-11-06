@echo off
echo ========================================
echo   DEPLOIEMENT KUBERNETES
echo ========================================

echo.
echo 1. Construction des images Docker...
cd /d "%~dp0.."
docker build -t gestion-notes/backend:latest ./appNotes
docker build -t gestion-notes/frontend:latest ./frontend

echo.
echo 2. Application des manifests Kubernetes...
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
kubectl apply -f k8s/04-mysql.yaml
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml
kubectl apply -f k8s/07-ingress.yaml

echo.
echo 3. Attente du demarrage des pods...
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=300s

echo.
echo 4. Verification du statut...
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes
kubectl get ingress -n gestion-notes

echo.
echo 5. Configuration de l'acces local...
echo Ajoutez cette ligne a votre fichier hosts:
echo 127.0.0.1 gestion-notes.local

echo.
echo Application accessible sur: http://gestion-notes.local
pause