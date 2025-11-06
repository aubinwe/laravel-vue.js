#!/bin/bash

set -e

echo "🚀 Déploiement DevOps Expert - Gestion Notes"

# Variables
NAMESPACE="gestion-notes"
BACKEND_IMAGE="gestion-notes-backend:latest"
FRONTEND_IMAGE="gestion-notes-frontend:latest"

# Fonction de log
log() {
    echo -e "\033[32m[$(date +'%H:%M:%S')] $1\033[0m"
}

error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
    exit 1
}

# 1. Vérifications préalables
log "🔍 Vérifications préalables..."
command -v docker >/dev/null 2>&1 || error "Docker non installé"
command -v kubectl >/dev/null 2>&1 || error "kubectl non installé"
kubectl cluster-info >/dev/null 2>&1 || error "Cluster Kubernetes inaccessible"

# 2. Build des images optimisées
log "🏗️ Construction des images optimisées..."

# Backend
log "📦 Build backend..."
cd appNotes
docker build -f Dockerfile.prod -t $BACKEND_IMAGE . || error "Build backend échoué"
cd ..

# Frontend
log "🎨 Build frontend..."
cd frontend
docker build -f Dockerfile.prod -t $FRONTEND_IMAGE . || error "Build frontend échoué"
cd ..

# 3. Chargement des images dans minikube
log "📤 Chargement des images dans minikube..."
minikube image load $BACKEND_IMAGE
minikube image load $FRONTEND_IMAGE

# 4. Déploiement Kubernetes
log "☸️ Déploiement sur Kubernetes..."
kubectl apply -f k8s-production.yaml

# 5. Attente du déploiement
log "⏳ Attente du déploiement..."
kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l app=backend -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n $NAMESPACE --timeout=300s

# 6. Tests post-déploiement
log "🧪 Tests post-déploiement..."

# Test MySQL
MYSQL_POD=$(kubectl get pods -n $NAMESPACE -l app=mysql -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n $NAMESPACE $MYSQL_POD -- mysqladmin ping -h localhost -u root -proot || error "MySQL non accessible"

# Test Backend
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=backend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n $NAMESPACE $BACKEND_POD -- curl -f http://localhost/api/health || error "Backend health check échoué"

# Test Frontend
FRONTEND_POD=$(kubectl get pods -n $NAMESPACE -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n $NAMESPACE $FRONTEND_POD -- curl -f http://localhost || error "Frontend non accessible"

# 7. Exposition du service
log "🌐 Exposition du service..."
MINIKUBE_IP=$(minikube ip)
FRONTEND_PORT=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')

# 8. Résultats
log "✅ Déploiement réussi!"
echo ""
echo "🌐 URLs d'accès:"
echo "   Application: http://$MINIKUBE_IP:$FRONTEND_PORT"
echo "   Backend API: http://$MINIKUBE_IP:$FRONTEND_PORT/api"
echo ""
echo "👤 Comptes de test:"
echo "   Admin: admin@gestion-notes.com / password"
echo "   Professeur: prof@test.com / password"
echo "   Étudiant: etudiant@test.com / password"
echo ""
echo "📊 Statut des pods:"
kubectl get pods -n $NAMESPACE

# 9. Ouvrir automatiquement dans le navigateur
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://$MINIKUBE_IP:$FRONTEND_PORT"
elif command -v open >/dev/null 2>&1; then
    open "http://$MINIKUBE_IP:$FRONTEND_PORT"
fi

log "🎉 Déploiement terminé avec succès!"