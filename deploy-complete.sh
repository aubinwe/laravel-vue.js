#!/bin/bash

echo "=========================================="
echo "   DÉPLOIEMENT DEVOPS COMPLET"
echo "=========================================="

# Phase 1: Docker Local
echo
echo "PHASE 1: TEST DOCKER LOCAL"
echo "----------------------------------------"

echo "1. Construction des images..."
docker build -t gestion-notes/backend:latest ./appNotes
docker build -t gestion-notes/frontend:latest ./frontend

echo "2. Démarrage Docker Compose..."
docker-compose -f docker-compose.prod.yml up -d

echo "3. Attente du démarrage (30s)..."
sleep 30

echo "4. Test de l'API..."
curl -f http://localhost:8000/api/health || echo "API non accessible"

echo "5. Test de l'application..."
curl -f http://localhost || echo "Frontend non accessible"

echo
echo "PHASE 1 TERMINÉE - Vérifiez http://localhost"
read -p "Appuyez sur Entrée pour continuer vers Kubernetes..."

# Phase 2: Kubernetes
echo
echo "PHASE 2: DÉPLOIEMENT KUBERNETES"
echo "----------------------------------------"

echo "1. Application des manifests..."
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secrets.yaml
kubectl apply -f k8s/04-mysql.yaml

echo "2. Attente de MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n gestion-notes --timeout=300s

echo "3. Déploiement Backend/Frontend..."
kubectl apply -f k8s/05-backend.yaml
kubectl apply -f k8s/06-frontend.yaml
kubectl apply -f k8s/07-ingress.yaml

echo "4. Attente des pods..."
kubectl wait --for=condition=ready pod -l app=backend -n gestion-notes --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n gestion-notes --timeout=300s

echo "5. Vérification..."
kubectl get pods -n gestion-notes

echo
echo "PHASE 2 TERMINÉE"
read -p "Appuyez sur Entrée pour continuer vers le Monitoring..."

# Phase 3: Monitoring
echo
echo "PHASE 3: DÉPLOIEMENT MONITORING"
echo "----------------------------------------"

echo "1. Déploiement Prometheus..."
kubectl apply -f k8s/monitoring/01-monitoring-namespace.yaml
kubectl apply -f k8s/monitoring/02-prometheus-config.yaml
kubectl apply -f k8s/monitoring/03-prometheus.yaml

echo "2. Déploiement Grafana..."
kubectl apply -f k8s/monitoring/05-grafana-dashboards.yaml
kubectl apply -f k8s/monitoring/04-grafana.yaml
kubectl apply -f k8s/monitoring/06-monitoring-ingress.yaml

echo "3. Attente des pods monitoring..."
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s

echo "4. Configuration port-forward..."
kubectl port-forward service/grafana-service 3000:3000 -n monitoring &
GRAFANA_PID=$!

kubectl port-forward service/prometheus-service 9090:9090 -n monitoring &
PROMETHEUS_PID=$!

echo
echo "=========================================="
echo "   DÉPLOIEMENT TERMINÉ !"
echo "=========================================="
echo
echo "🐳 DOCKER:"
echo "   Application: http://localhost"
echo "   API: http://localhost:8000/api"
echo
echo "☸️  KUBERNETES:"
echo "   Pods: kubectl get pods -n gestion-notes"
echo "   Services: kubectl get svc -n gestion-notes"
echo
echo "📊 MONITORING:"
echo "   Grafana: http://localhost:3000 (admin/admin123)"
echo "   Prometheus: http://localhost:9090"
echo
echo "👤 COMPTES TEST:"
echo "   Admin: admin@gestion-notes.com / password"
echo "   Prof: prof@test.com / password"
echo "   Étudiant: etudiant@test.com / password"
echo
echo "Appuyez sur Ctrl+C pour arrêter les port-forwards"

trap "kill $GRAFANA_PID $PROMETHEUS_PID 2>/dev/null; exit" INT
wait