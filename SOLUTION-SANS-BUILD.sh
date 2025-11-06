#!/bin/bash

echo "=== SOLUTION SANS BUILD DOCKER ==="

# Nettoyer
docker-compose down -v 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 1. Build frontend localement
echo "Build frontend local..."
cd frontend
npm install
npm run build
cd ..

# 2. Préparer backend
echo "Préparation backend..."
cd appNotes
composer install --no-dev --optimize-autoloader
cd ..

# 3. Démarrer MySQL
echo "MySQL..."
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0

sleep 30

# 4. Démarrer Backend (sans build)
echo "Backend..."
docker run -d --name backend \
  --link mysql:mysql \
  -v $(pwd)/appNotes:/var/www/html \
  -p 8000:8000 \
  -e DB_HOST=mysql \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  php:8.2-apache sh -c "
    apt-get update && apt-get install -y git curl zip unzip default-mysql-client &&
    docker-php-ext-install pdo pdo_mysql &&
    a2enmod rewrite &&
    cd /var/www/html &&
    sleep 30 &&
    php artisan migrate:fresh --seed --force &&
    php artisan serve --host=0.0.0.0 --port=8000
  "

sleep 60

# 5. Démarrer Frontend (sans build)
echo "Frontend..."
docker run -d --name frontend \
  --link backend:backend \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  -p 80:80 \
  nginx:alpine sh -c "
    echo 'server {
      listen 80;
      root /usr/share/nginx/html;
      index index.html;
      location / { try_files \$uri \$uri/ /index.html; }
      location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host \$host;
      }
    }' > /etc/nginx/conf.d/default.conf &&
    nginx -g 'daemon off;'
  "

sleep 20

# 6. Monitoring
echo "Prometheus..."
docker run -d --name prometheus \
  --link backend:backend \
  -p 9090:9090 \
  -v $(pwd)/monitoring/prometheus-working.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

echo "Grafana..."
docker run -d --name grafana \
  --link prometheus:prometheus \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

sleep 30

# Tests
echo ""
echo "=== TESTS ==="
curl -s http://localhost >/dev/null && echo "App: ✅" || echo "App: ❌"
curl -s http://localhost:8000/api/health >/dev/null && echo "Backend: ✅" || echo "Backend: ❌"
curl -s http://localhost:8000/metrics >/dev/null && echo "Metrics: ✅" || echo "Metrics: ❌"
curl -s http://localhost:9090 >/dev/null && echo "Prometheus: ✅" || echo "Prometheus: ❌"
curl -s http://localhost:3000 >/dev/null && echo "Grafana: ✅" || echo "Grafana: ❌"

echo ""
echo "=== ACCES ==="
echo "App: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "Identifiants: admin@gestion-notes.com / password"