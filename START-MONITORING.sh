#!/bin/bash

echo "=== DEMARRAGE MONITORING ==="

# Arrêter anciens conteneurs
docker-compose -f docker-compose.monitoring.yml down -v

# Démarrer
docker-compose -f docker-compose.monitoring.yml up -d

# Attendre
sleep 60

# Vérifier
docker-compose -f docker-compose.monitoring.yml ps

echo ""
echo "=== ACCES ==="
echo "App: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Métriques: http://localhost:8000/api/metrics"