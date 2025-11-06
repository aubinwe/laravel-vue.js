#!/bin/bash

echo "=== DEPLOIEMENT AVEC MONITORING ==="

# Démarrer avec monitoring
docker-compose -f docker-compose.monitoring.yml up -d

echo "Attente des services..."
sleep 60

echo "=== SERVICES DISPONIBLES ==="
echo "Application: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Node Exporter: http://localhost:9100"
echo "cAdvisor: http://localhost:8080"
echo "Alertmanager: http://localhost:9093"

echo ""
echo "=== CONFIGURATION GRAFANA ==="
echo "1. Connectez-vous à Grafana (admin/admin)"
echo "2. Ajoutez Prometheus comme source de données: http://prometheus:9090"
echo "3. Importez le dashboard depuis monitoring/grafana/dashboards/"

echo ""
echo "=== METRIQUES DISPONIBLES ==="
echo "- Application: http://localhost:8000/api/metrics"
echo "- Système: http://localhost:9100/metrics"
echo "- Conteneurs: http://localhost:8080/metrics"

echo ""
echo "=== ALERTES ==="
echo "Les alertes sont configurées pour:"
echo "- Taux d'erreur élevé (>10%)"
echo "- Temps de réponse élevé (>1s)"
echo "- Base de données indisponible"
echo "- CPU élevé (>80%)"
echo "- Mémoire élevée (>85%)"