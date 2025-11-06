#!/bin/bash

echo "=== DEPLOIEMENT MONITORING LOCAL ==="

# Arrêter les anciens conteneurs
docker-compose down -v 2>/dev/null || true

# Créer le réseau si nécessaire
docker network create monitoring-network 2>/dev/null || true

# Démarrer MySQL d'abord
echo "Démarrage MySQL..."
docker run -d --name mysql --network monitoring-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0

# Attendre MySQL
echo "Attente MySQL..."
sleep 30

# Démarrer Backend
echo "Build et démarrage Backend..."
cd appNotes
docker build -t backend-local .
docker run -d --name backend --network monitoring-network \
  -e DB_HOST=mysql \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  -p 8000:8000 \
  backend-local sh -c "sleep 30 && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=8000"

cd ..

# Démarrer Frontend
echo "Build et démarrage Frontend..."
cd frontend
docker build -t frontend-local .
docker run -d --name frontend --network monitoring-network \
  -p 80:80 \
  frontend-local
cd ..

# Démarrer Prometheus
echo "Démarrage Prometheus..."
docker run -d --name prometheus --network monitoring-network \
  -p 9090:9090 \
  -v $(pwd)/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v $(pwd)/monitoring/alert_rules.yml:/etc/prometheus/alert_rules.yml \
  prom/prometheus:latest

# Démarrer Grafana
echo "Démarrage Grafana..."
docker run -d --name grafana --network monitoring-network \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

# Démarrer Node Exporter
echo "Démarrage Node Exporter..."
docker run -d --name node-exporter --network monitoring-network \
  -p 9100:9100 \
  prom/node-exporter:latest

# Attendre que tout soit prêt
echo "Attente des services..."
sleep 60

echo ""
echo "=== SERVICES DISPONIBLES ==="
echo "✅ Application: http://localhost"
echo "✅ Backend API: http://localhost:8000"
echo "✅ Prometheus: http://localhost:9090"
echo "✅ Grafana: http://localhost:3000 (admin/admin)"
echo "✅ Node Exporter: http://localhost:9100"
echo "✅ Métriques App: http://localhost:8000/api/metrics"

echo ""
echo "=== CONFIGURATION GRAFANA ==="
echo "1. Aller sur http://localhost:3000"
echo "2. Login: admin/admin"
echo "3. Ajouter source de données Prometheus: http://prometheus:9090"
echo "4. Créer des dashboards avec les métriques disponibles"

echo ""
echo "=== COMMANDES UTILES ==="
echo "Voir les logs: docker logs <container-name>"
echo "Arrêter tout: docker stop mysql backend frontend prometheus grafana node-exporter"
echo "Nettoyer: docker rm mysql backend frontend prometheus grafana node-exporter"