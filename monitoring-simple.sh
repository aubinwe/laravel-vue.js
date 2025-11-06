#!/bin/bash

echo "=== DÉPLOIEMENT MONITORING ==="

# 1. Déployer monitoring
echo "1. Déploiement monitoring..."
kubectl apply -f k8s/monitoring/

# 2. Attendre
echo "2. Attente des pods monitoring..."
sleep 60

# 3. Statut
echo "3. Statut monitoring..."
kubectl get pods -n monitoring

echo "=== ACCÈS MONITORING ==="
echo "Grafana: kubectl port-forward -n monitoring service/grafana-service 3000:3000"
echo "Login: admin / admin123"