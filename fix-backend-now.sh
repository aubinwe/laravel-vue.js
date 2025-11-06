#!/bin/bash

echo "=== CORRECTION BACKEND IMMEDIATE ==="

# Voir les logs du backend
echo "Logs backend:"
docker-compose -f docker-compose.monitoring.yml logs backend

echo ""
echo "=== REDEMARRAGE BACKEND ==="
docker-compose -f docker-compose.monitoring.yml restart backend

# Attendre et suivre les logs
echo "Suivi des logs en temps réel..."
timeout 60 docker-compose -f docker-compose.monitoring.yml logs -f backend &

# Attendre que le backend soit prêt
echo "Attente du backend..."
for i in {1..30}; do
    if curl -s http://localhost:8000/api/health >/dev/null 2>&1; then
        echo "Backend prêt après ${i}0 secondes"
        break
    fi
    echo "Tentative $i/30..."
    sleep 10
done

# Test final
echo ""
echo "=== TEST FINAL ==="
curl -s http://localhost:8000/api/health && echo "Health: OK" || echo "Health: KO"
curl -s http://localhost:8000/api/metrics | head -3 && echo "Metrics: OK" || echo "Metrics: KO"

# Vérifier Prometheus
echo ""
echo "=== PROMETHEUS ==="
curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"[^"]*"' | head -3