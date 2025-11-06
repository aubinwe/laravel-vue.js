#!/bin/bash

echo "=== DÉPLOIEMENT KUBERNETES ==="

# 1. Démarrer minikube
echo "1. Démarrage minikube..."
minikube start --driver=docker --memory=3072 --cpus=2

# 2. Construire les images
echo "2. Construction des images..."
eval $(minikube docker-env)
docker build -t gestion-notes/backend:latest ./appNotes
docker build -t gestion-notes/frontend:latest ./frontend

# 3. Déployer
echo "3. Déploiement..."
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
kubectl apply -f k8s/04-mysql.yaml
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml

# 4. Attendre
echo "4. Attente des pods..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=300s

# 5. Statut
echo "5. Statut final..."
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

echo "=== ACCÈS ==="
echo "Frontend: kubectl port-forward -n gestion-notes service/frontend-service 8080:80"
echo "Backend:  kubectl port-forward -n gestion-notes service/backend-service 8000:8000"