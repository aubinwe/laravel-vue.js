#!/bin/bash

echo "=== MONITORING SIMPLE ==="

# Arrêter tout
docker-compose down -v 2>/dev/null || true

# Démarrer MySQL
echo "MySQL..."
docker run -d --name mysql --network bridge \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 mysql:8.0

sleep 30

# Démarrer Backend
echo "Backend..."
cd appNotes
docker build -t backend-simple .
docker run -d --name backend --network bridge \
  --link mysql:mysql \
  -e DB_HOST=mysql \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  -p 8000:8000 \
  backend-simple sh -c "sleep 20 && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=8000"

cd ..
sleep 30

# Test backend
echo "Test backend..."
curl -s http://localhost:8000/api/health && echo " - Backend OK" || echo " - Backend KO"
curl -s http://localhost:8000/api/metrics | head -3

# Démarrer Prometheus
echo "Prometheus..."
docker run -d --name prometheus --network bridge \
  --link backend:backend \
  -p 9090:9090 \
  -v $(pwd)/monitoring/prometheus-simple.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

# Démarrer Grafana
echo "Grafana..."
docker run -d --name grafana --network bridge \
  --link prometheus:prometheus \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

sleep 20

echo ""
echo "=== SERVICES ==="
echo "Backend: http://localhost:8000"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Métriques: http://localhost:8000/api/metrics"

echo ""
echo "Dans Grafana:"
echo "1. Data Source: http://prometheus:9090"
echo "2. Query: app_users_total"