#!/bin/bash

echo "=== DEPLOIEMENT IMMEDIAT ==="

# Rendre exécutable
chmod +x *.sh

# Vérifier kubectl
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERREUR: Kubernetes non accessible"
    echo "Démarrez minikube:"
    echo "minikube start"
    exit 1
fi

# Supprimer ancien déploiement
echo "Nettoyage..."
kubectl delete namespace gestion-notes --ignore-not-found=true
sleep 10

# Build des images
echo "Build backend..."
cd appNotes
docker build -t appnotes-backend:latest .
cd ..

echo "Build frontend..."
cd frontend
docker build -t appnotes-frontend:latest .
cd ..

# Déploiement étape par étape
echo "Création namespace..."
kubectl apply -f k8s-production/01-namespace.yaml

echo "Configuration..."
kubectl apply -f k8s-production/02-configmap.yaml
kubectl apply -f k8s-production/03-secret.yaml

echo "MySQL..."
kubectl apply -f k8s-production/04-mysql.yaml
sleep 30

echo "Backend..."
kubectl apply -f k8s-production/05-backend.yaml
sleep 20

echo "Frontend..."
kubectl apply -f k8s-production/06-frontend.yaml
sleep 10

echo "Vérification..."
kubectl get all -n gestion-notes

echo ""
echo "=== ACCES ==="
echo "NodePort: http://localhost:30080"
echo "Port-forward: kubectl port-forward service/frontend-service 8080:80 -n gestion-notes"