#!/bin/bash
set -e

echo "=== DEPLOIEMENT KUBERNETES ==="

# 1. Vérifier minikube
if ! minikube status | grep -q "Running"; then
    echo "Démarrage minikube..."
    minikube start --driver=docker
fi

# 2. Utiliser Docker de minikube
eval $(minikube docker-env)

# 3. Build images
echo "Build backend..."
cd appNotes
docker build -t appnotes-backend:latest .
cd ../frontend
echo "Build frontend..."
docker build -t appnotes-frontend:latest .
cd ..

# 4. Supprimer ancien déploiement
kubectl delete namespace gestion-notes --ignore-not-found=true
sleep 15

# 5. Déployer
echo "Déploiement..."
kubectl apply -f k8s-final.yaml

# 6. Attendre les pods
echo "Attente des pods..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=180s

# 7. Afficher l'URL
echo ""
echo "=== APPLICATION DEPLOYEE ==="
echo "URL: http://$(minikube ip):30080"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"