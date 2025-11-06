#!/bin/bash

echo "🚀 TEST PIPELINE COMPLET - DOCKER À GRAFANA"
echo "============================================="

# Phase 1: Docker (déjà fonctionnel)
echo
echo "✅ PHASE 1: DOCKER - DÉJÀ FONCTIONNEL"
echo "   Backend: http://localhost:8000/api/health"
curl -s http://localhost:8000/api/health && echo " ✅" || echo " ❌"

# Phase 2: Construction images pour Kubernetes
echo
echo "📦 PHASE 2: CONSTRUCTION IMAGES K8S"
echo "Construction backend..."
docker build -t gestion-notes/backend:latest ./appNotes

echo "Construction frontend..."
cd frontend && npm run build && cd ..
docker build -t gestion-notes/frontend:latest ./frontend

# Phase 3: Déploiement Kubernetes
echo
echo "☸️  PHASE 3: DÉPLOIEMENT KUBERNETES"
echo "Application des manifests..."
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
kubectl apply -f k8s/04-mysql.yaml

echo "Attente MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=180s

echo "Déploiement app..."
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml

echo "Attente pods..."
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=180s

# Phase 4: Monitoring
echo
echo "📊 PHASE 4: DÉPLOIEMENT MONITORING"
kubectl apply -f k8s/monitoring/

echo "Attente monitoring..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=180s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=180s

# Phase 5: Port-forwards
echo
echo "🔗 PHASE 5: CONFIGURATION ACCÈS"
kubectl port-forward service/backend-service 8001:8000 -n gestion-notes >/dev/null 2>&1 &
kubectl port-forward service/frontend-service 8080:80 -n gestion-notes >/dev/null 2>&1 &
kubectl port-forward service/grafana-service 3000:3000 -n monitoring >/dev/null 2>&1 &
kubectl port-forward service/prometheus-service 9090:9090 -n monitoring >/dev/null 2>&1 &

sleep 10

# Phase 6: Tests finaux
echo
echo "🧪 PHASE 6: TESTS FINAUX"
echo "Test K8s Backend:"
curl -s http://localhost:8001/api/health && echo " ✅" || echo " ❌"

echo "Test Prometheus:"
curl -s http://localhost:9090/-/healthy && echo " ✅" || echo " ❌"

echo "Test Grafana:"
curl -s http://localhost:3000/api/health && echo " ✅" || echo " ❌"

echo
echo "🎉 PIPELINE TERMINÉ !"
echo "===================="
echo
echo "🐳 DOCKER:"
echo "   Backend: http://localhost:8000/api/health"
echo
echo "☸️  KUBERNETES:"
echo "   Backend: http://localhost:8001/api/health"
echo "   Frontend: http://localhost:8080"
echo
echo "📊 MONITORING:"
echo "   Grafana: http://localhost:3000 (admin/admin123)"
echo "   Prometheus: http://localhost:9090"
echo
echo "📋 VÉRIFICATIONS:"
echo "   kubectl get pods -n gestion-notes"
echo "   kubectl get pods -n monitoring"
echo
echo "Appuyez sur Ctrl+C pour arrêter les port-forwards"
wait