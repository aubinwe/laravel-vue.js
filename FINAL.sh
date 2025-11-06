#!/bin/bash
set -e

echo "=== DEPLOIEMENT KUBERNETES FINAL ==="

# Démarrer minikube
minikube start --driver=docker
eval $(minikube docker-env)

# Build backend
echo "Build backend..."
cd appNotes
docker build -t appnotes-backend:latest .
cd ..

# Build frontend  
echo "Build frontend..."
cd frontend
docker build -t appnotes-frontend:latest .
cd ..

# Nettoyage
kubectl delete namespace gestion-notes --ignore-not-found=true
sleep 10

# Déploiement direct
kubectl create namespace gestion-notes

# MySQL
kubectl run mysql --image=mysql:8.0 \
  --env="MYSQL_ROOT_PASSWORD=root" \
  --env="MYSQL_DATABASE=gestion_notes" \
  --port=3306 -n gestion-notes

kubectl expose pod mysql --port=3306 --name=mysql -n gestion-notes
kubectl wait --for=condition=ready pod mysql -n gestion-notes --timeout=300s

# Backend
kubectl run backend --image=appnotes-backend:latest \
  --image-pull-policy=Never --port=8000 -n gestion-notes \
  --env="DB_HOST=mysql" \
  --env="DB_DATABASE=gestion_notes" \
  --env="DB_USERNAME=root" \
  --env="DB_PASSWORD=root" \
  --env="APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs="

kubectl expose pod backend --port=8000 --name=backend -n gestion-notes
kubectl wait --for=condition=ready pod backend -n gestion-notes --timeout=300s

# Init base
sleep 30
kubectl exec backend -n gestion-notes -- php artisan migrate:fresh --seed --force

# Frontend
kubectl run frontend --image=appnotes-frontend:latest \
  --image-pull-policy=Never --port=80 -n gestion-notes

kubectl expose pod frontend --port=80 --type=NodePort --name=frontend -n gestion-notes
kubectl wait --for=condition=ready pod frontend -n gestion-notes --timeout=180s

echo ""
echo "=== APPLICATION DEPLOYEE ==="
echo "URL: http://$(minikube ip):$(kubectl get service frontend -n gestion-notes -o jsonpath='{.spec.ports[0].nodePort}')"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"  
echo "etudiant@test.com / password"