#!/bin/bash

echo "=== TEST ENDPOINT METRICS ==="

# Attendre que le backend soit prêt
echo "Attente du backend..."
sleep 30

# Tester l'endpoint metrics
echo "Test de l'endpoint metrics..."
curl -v http://localhost:8000/api/metrics

echo ""
echo "=== VERIFICATION PROMETHEUS ==="
echo "Vérification de la configuration Prometheus..."
curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"[^"]*"'

echo ""
echo "=== REDEMARRAGE SI NECESSAIRE ==="
docker-compose -f docker-compose.monitoring.yml restart backend
sleep 20

echo "Test final..."
curl -s http://localhost:8000/api/metrics | head -10