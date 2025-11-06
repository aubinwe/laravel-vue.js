#!/bin/bash
echo "=== DEPLOIEMENT WSL AVEC MONITORING ==="

# Créer les dossiers nécessaires
mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p monitoring/grafana/provisioning/dashboards

# Démarrer les services
docker-compose up -d

# Attendre que les services soient prêts
echo "Attente des services..."
sleep 30

# Vérifier l'état
docker-compose ps

echo "=== SERVICES DISPONIBLES ==="
echo "Application: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Backend API: http://localhost:8000"

# Ouvrir dans le navigateur (WSL)
if command -v wslview &> /dev/null; then
    wslview http://localhost &
    wslview http://localhost:3000 &
fi