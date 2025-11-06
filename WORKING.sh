#!/bin/bash
set -e

echo "=== DEPLOIEMENT QUI MARCHE ==="

minikube start --driver=docker
eval $(minikube docker-env)

# Build
cd appNotes && docker build -t backend:v1 . && cd ..
cd frontend && docker build -t frontend:v1 . && cd ..

# Clean
kubectl delete namespace gestion-notes --ignore-not-found=true
sleep 10
kubectl create namespace gestion-notes

# MySQL
kubectl run mysql --image=mysql:8.0 \
  --env="MYSQL_ROOT_PASSWORD=root" \
  --env="MYSQL_DATABASE=gestion_notes" \
  --port=3306 -n gestion-notes

kubectl expose pod mysql --port=3306 --name=mysql -n gestion-notes

# Attendre MySQL vraiment prêt
echo "Attente MySQL..."
kubectl wait --for=condition=ready pod mysql -n gestion-notes --timeout=300s
sleep 60

# Test connexion MySQL
kubectl run mysql-test --image=mysql:8.0 --rm -i --restart=Never -n gestion-notes -- \
  mysql -h mysql -u root -proot -e "SELECT 'MySQL OK';"

# Backend avec attente
kubectl run backend --image=backend:v1 --image-pull-policy=Never -n gestion-notes \
  --env="DB_HOST=mysql" \
  --env="DB_DATABASE=gestion_notes" \
  --env="DB_USERNAME=root" \
  --env="DB_PASSWORD=root" \
  --env="APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs=" \
  --command -- /bin/sh -c "
    echo 'Attente MySQL...'
    until nc -z mysql 3306; do sleep 5; done
    sleep 30
    echo 'Migration...'
    php artisan migrate:fresh --seed --force
    echo 'Serveur...'
    php artisan serve --host=0.0.0.0 --port=8000
  "

kubectl expose pod backend --port=8000 --name=backend -n gestion-notes
kubectl wait --for=condition=ready pod backend -n gestion-notes --timeout=300s

# Frontend
kubectl run frontend --image=frontend:v1 --image-pull-policy=Never --port=80 -n gestion-notes
kubectl expose pod frontend --port=80 --type=NodePort --name=frontend -n gestion-notes

echo ""
echo "=== SUCCES ==="
minikube service frontend -n gestion-notes --url