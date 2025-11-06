#!/bin/bash

echo "=== DEPLOIEMENT SIMPLE AVEC MINIKUBE ==="

# Vérifier minikube
if ! command -v minikube &> /dev/null; then
    echo "Installation de minikube..."
    ./install-minikube.sh
fi

# Démarrer minikube si pas déjà fait
minikube status | grep -q "Running" || minikube start

# Utiliser le Docker de minikube
eval $(minikube docker-env)

# Build des images dans minikube
echo "Build des images..."
cd appNotes
docker build -t appnotes-backend:latest .
cd ../frontend  
docker build -t appnotes-frontend:latest .
cd ..

# Déploiement
echo "Déploiement..."
kubectl apply -f k8s-production/

# Attendre les pods
echo "Attente des pods..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=180s

# Statut
kubectl get pods -n gestion-notes

# URL d'accès
echo ""
echo "=== ACCES A L'APPLICATION ==="
minikube service frontend-service -n gestion-notes --url

echo ""
echo "Pour ouvrir dans le navigateur:"
echo "minikube service frontend-service -n gestion-notes"