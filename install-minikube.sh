#!/bin/bash

echo "=== INSTALLATION MINIKUBE ==="

# Installation de minikube
echo "Téléchargement de minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Démarrage de minikube
echo "Démarrage de minikube..."
minikube start --driver=docker

# Vérification
echo "Vérification..."
kubectl cluster-info

echo ""
echo "=== MINIKUBE PRÊT ==="
echo "Pour accéder aux services:"
echo "minikube service frontend-service -n gestion-notes --url"