#!/bin/bash

echo "=== CONFIGURATION KUBERNETES ==="

# Vérifier si Docker Desktop est installé
if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installé"
    echo "Installez Docker Desktop depuis: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Vérifier si kubectl est installé
if ! command -v kubectl &> /dev/null; then
    echo "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# Vérifier le statut de Docker
echo "Vérification de Docker..."
docker version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERREUR: Docker n'est pas démarré"
    echo "Démarrez Docker Desktop et activez Kubernetes"
    exit 1
fi

# Vérifier si Kubernetes est activé dans Docker Desktop
echo "Vérification de Kubernetes..."
kubectl cluster-info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERREUR: Kubernetes n'est pas activé"
    echo ""
    echo "Pour activer Kubernetes dans Docker Desktop:"
    echo "1. Ouvrez Docker Desktop"
    echo "2. Allez dans Settings > Kubernetes"
    echo "3. Cochez 'Enable Kubernetes'"
    echo "4. Cliquez 'Apply & Restart'"
    echo ""
    echo "Ou utilisez minikube:"
    echo "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    echo "sudo install minikube-linux-amd64 /usr/local/bin/minikube"
    echo "minikube start"
    exit 1
fi

echo "Kubernetes est prêt!"
kubectl cluster-info