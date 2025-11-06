#!/bin/bash

echo "=== KUBERNETES CORRECTION ==="

# 1. Reset minikube
echo "1. Reset minikube..."
minikube delete
minikube start --driver=docker --memory=3072 --cpus=2 --kubernetes-version=v1.28.3

# 2. Attendre que minikube soit prêt
echo "2. Attente minikube..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 3. Construire images dans minikube
echo "3. Construction images..."
eval $(minikube docker-env)
docker build -t gestion-notes/backend:latest ./appNotes
docker build -t gestion-notes/frontend:latest ./frontend

# 4. Déployer par étapes
echo "4. Déploiement..."
kubectl apply -f k8s/01-namespace.yaml
sleep 5
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
sleep 5
kubectl apply -f k8s/04-mysql.yaml
sleep 30
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml

# 5. Vérifier
echo "5. Vérification..."
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

echo "=== ACCÈS K8S ==="
echo "kubectl port-forward -n gestion-notes service/frontend-service 8080:80"
echo "kubectl port-forward -n gestion-notes service/backend-service 8001:8000"