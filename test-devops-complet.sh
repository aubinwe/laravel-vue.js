#!/bin/bash

echo "========================================"
echo "   TEST COMPLET DEVOPS - GESTION NOTES"
echo "========================================"

echo
echo "[1/6] Vérification des prérequis..."
if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installé"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "ERREUR: kubectl n'est pas installé"
    exit 1
fi

echo "✓ Docker et kubectl détectés"

echo
echo "[2/6] Construction des images Docker..."
docker-compose build --no-cache
if [ $? -ne 0 ]; then
    echo "ERREUR: Échec de construction des images"
    exit 1
fi
echo "✓ Images construites avec succès"

echo
echo "[3/6] Test Docker Compose..."
docker-compose up -d
sleep 30
docker-compose ps
echo "✓ Application démarrée avec Docker Compose"

echo
echo "[4/6] Nettoyage Docker Compose..."
docker-compose down
echo "✓ Docker Compose arrêté"

echo
echo "[5/6] Démarrage Kubernetes..."
if ! minikube status &> /dev/null; then
    echo "Démarrage de minikube..."
    minikube start --driver=docker --memory=3072 --cpus=2
    minikube addons enable ingress
    minikube addons enable metrics-server
fi

echo
echo "[6/6] Déploiement sur Kubernetes..."
kubectl apply -f k8s/
echo "✓ Application déployée sur Kubernetes"

echo
echo "Attente du démarrage des pods..."
sleep 60

echo
echo "========================================"
echo "           STATUT FINAL"
echo "========================================"
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

echo
echo "========================================"
echo "         ACCÈS AUX SERVICES"
echo "========================================"
echo "Frontend: kubectl port-forward -n gestion-notes service/frontend-service 8080:80"
echo "Backend:  kubectl port-forward -n gestion-notes service/backend-service 8000:8000"
echo
echo "Puis accéder à: http://localhost:8080"