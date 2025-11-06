#!/bin/bash

echo "=== RESET TOTAL ET REDEMARRAGE ==="

# Arrêter et nettoyer TOUT
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -af

# Redémarrer l'application de base d'abord
echo "=== 1. APPLICATION DE BASE ==="

# MySQL
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0

sleep 30

# Backend
cd appNotes
docker build -t backend-app . || exit 1
docker run -d --name backend \
  --link mysql:mysql \
  -e DB_HOST=mysql \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  -p 8000:8000 \
  backend-app sh -c "sleep 30 && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=8000"

cd ..

# Frontend
cd frontend
npm install
npm run build
cd ..

docker run -d --name frontend \
  --link backend:backend \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  -p 80:80 \
  nginx:alpine

sleep 30

echo "=== TEST APPLICATION ==="
curl -s http://localhost:8000/api/health && echo "Backend: ✅" || echo "Backend: ❌"
curl -s http://localhost/index.html >/dev/null && echo "Frontend: ✅" || echo "Frontend: ❌"
curl -s http://localhost:8000/metrics | head -3 && echo "Metrics: ✅" || echo "Metrics: ❌"

# Monitoring seulement si l'app marche
if curl -s http://localhost:8000/api/health >/dev/null; then
    echo ""
    echo "=== 2. MONITORING ==="
    
    # Prometheus
    docker run -d --name prometheus \
      --link backend:backend \
      -p 9090:9090 \
      -v $(pwd)/monitoring/prometheus-final.yml:/etc/prometheus/prometheus.yml \
      prom/prometheus:latest
    
    # Grafana
    docker run -d --name grafana \
      --link prometheus:prometheus \
      -p 3000:3000 \
      -e GF_SECURITY_ADMIN_PASSWORD=admin \
      grafana/grafana:latest
    
    sleep 20
    
    echo "=== TEST MONITORING ==="
    curl -s http://localhost:9090/-/healthy && echo "Prometheus: ✅" || echo "Prometheus: ❌"
    curl -s http://localhost:3000/api/health && echo "Grafana: ✅" || echo "Grafana: ❌"
fi

echo ""
echo "=== RESULTAT FINAL ==="
echo "Application: http://localhost"
echo "Backend API: http://localhost:8000"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "Identifiants app:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"

echo ""
echo "=== STATUT CONTENEURS ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"