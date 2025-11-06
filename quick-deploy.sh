#!/bin/bash

echo "=== DEPLOIEMENT RAPIDE ==="

# Rendre les scripts executables
chmod +x *.sh

# Build des images
echo "Build backend..."
cd appNotes && docker build -t appnotes-backend:latest . && cd ..

echo "Build frontend..."
cd frontend && docker build -t appnotes-frontend:latest . && cd ..

# Deploiement
echo "Deploiement..."
kubectl apply -f k8s-production/

# Attendre les pods
echo "Attente des pods..."
sleep 30

# Statut
kubectl get pods -n gestion-notes

echo ""
echo "=== ACCES ==="
echo "NodePort: http://localhost:30080"
echo "Port-forward: kubectl port-forward service/frontend-service 8080:80 -n gestion-notes"