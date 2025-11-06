#!/bin/bash

echo "=== MONITORING RAPIDE ==="

# Nettoyer d'abord
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Démarrer l'application de base
echo "Démarrage application..."
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gestion_notes -p 3306:3306 mysql:8.0

sleep 30

cd appNotes && docker build -t backend . && cd ..
docker run -d --name backend --link mysql:mysql -e DB_HOST=mysql -e DB_DATABASE=gestion_notes -e DB_USERNAME=root -e DB_PASSWORD=root -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= -p 8000:8000 backend sh -c "sleep 20 && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=8000"

cd frontend && docker build -t frontend . && cd ..
docker run -d --name frontend --link backend:backend -p 80:80 frontend

# Démarrer monitoring
echo "Démarrage monitoring..."
docker run -d --name prometheus --link backend:backend -p 9090:9090 -v $(pwd)/monitoring/prometheus-local.yml:/etc/prometheus/prometheus.yml prom/prometheus:latest

docker run -d --name grafana -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana:latest

sleep 30

echo ""
echo "=== TOUT EST PRET ==="
echo "App: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Métriques: http://localhost:8000/api/metrics"

echo ""
echo "Identifiants app:"
echo "admin@gestion-notes.com / password"