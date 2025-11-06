#!/bin/bash

echo "⚡ TEST RAPIDE KUBERNETES + MONITORING"

# Déploiement rapide
kubectl apply -f k8s/ >/dev/null 2>&1
kubectl apply -f k8s/monitoring/ >/dev/null 2>&1

echo "⏳ Attente 60s..."
sleep 60

# Port-forwards
kubectl port-forward service/grafana-service 3000:3000 -n monitoring >/dev/null 2>&1 &
kubectl port-forward service/prometheus-service 9090:9090 -n monitoring >/dev/null 2>&1 &
kubectl port-forward service/backend-service 8001:8000 -n gestion-notes >/dev/null 2>&1 &

sleep 5

echo
echo "🎯 ACCÈS RAPIDE:"
echo "   Grafana: http://localhost:3000 (admin/admin123)"
echo "   Prometheus: http://localhost:9090"
echo "   K8s Backend: http://localhost:8001/api/health"
echo
echo "📊 STATUT:"
kubectl get pods -n gestion-notes
kubectl get pods -n monitoring

echo
echo "Ctrl+C pour arrêter"
wait