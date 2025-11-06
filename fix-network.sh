#!/bin/bash

echo "=== CORRECTION RESEAU ==="

# Arrêter tout
docker-compose -f docker-compose.monitoring.yml down

# Vérifier le statut du backend
echo "Vérification backend..."
docker-compose -f docker-compose.monitoring.yml ps backend

# Redémarrer avec logs
echo "Redémarrage avec logs..."
docker-compose -f docker-compose.monitoring.yml up -d

# Attendre
sleep 30

# Vérifier les conteneurs
echo "=== STATUT CONTENEURS ==="
docker-compose -f docker-compose.monitoring.yml ps

# Tester la connectivité
echo "=== TEST CONNECTIVITE ==="
echo "Test backend depuis host..."
curl -s http://localhost:8000/api/health && echo " - Backend OK" || echo " - Backend KO"

echo "Test metrics depuis host..."
curl -s http://localhost:8000/api/metrics | head -3

# Tester depuis Prometheus
echo "Test depuis conteneur Prometheus..."
docker-compose -f docker-compose.monitoring.yml exec prometheus wget -qO- http://host.docker.internal:8000/api/metrics | head -3

echo ""
echo "=== LOGS BACKEND ==="
docker-compose -f docker-compose.monitoring.yml logs backend | tail -10