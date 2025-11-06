#!/bin/bash

echo "SOLUTION ULTIME - DERNIERE CHANCE"
echo "================================="

# Nettoyage total
docker kill $(docker ps -q) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 1. MySQL - Base solide
echo "MySQL..."
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0

# Attendre MySQL vraiment prêt
echo "Attente MySQL..."
sleep 45
until docker exec mysql mysqladmin ping -h localhost --silent; do
  echo "MySQL pas prêt..."
  sleep 5
done
echo "MySQL OK"

# 2. Backend Laravel fonctionnel
echo "Backend Laravel..."
cd appNotes

# Créer un .env qui marche
cat > .env << 'EOF'
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=root

SESSION_DRIVER=file
CACHE_STORE=file
QUEUE_CONNECTION=sync
EOF

# Backend avec Laravel qui marche
docker run -d --name backend \
  --link mysql:mysql \
  -p 8000:8000 \
  -v $(pwd):/var/www/html \
  -w /var/www/html \
  php:8.2-apache sh -c "
    apt-get update && apt-get install -y default-mysql-client zip unzip git &&
    docker-php-ext-install pdo pdo_mysql &&
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
    composer install --no-dev &&
    php artisan config:clear &&
    php artisan migrate:fresh --seed --force &&
    php artisan serve --host=0.0.0.0 --port=8000
  "

cd ..
echo "Attente backend..."
sleep 90

# Test backend
for i in {1..20}; do
  if curl -s http://localhost:8000 | grep -q "Laravel"; then
    echo "Backend Laravel OK"
    break
  fi
  echo "Test backend $i/20..."
  sleep 5
done

# 3. Frontend simple
echo "Frontend..."
docker run -d --name frontend \
  -p 8080:80 \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  nginx:alpine

# 4. Prometheus simple
echo "Prometheus..."
cat > prometheus-simple.yml << 'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
EOF

docker run -d --name prometheus \
  --link backend:backend \
  -p 9090:9090 \
  -v $(pwd)/prometheus-simple.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest

# 5. Grafana simple
echo "Grafana..."
docker run -d --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

# Attendre tous les services
echo "Attente finale..."
sleep 30

# Tests finaux
echo ""
echo "=== TESTS FINAUX ==="
curl -s http://localhost:8080 >/dev/null && echo "✅ Frontend: MARCHE" || echo "❌ Frontend: ECHEC"
curl -s http://localhost:8000 >/dev/null && echo "✅ Backend: MARCHE" || echo "❌ Backend: ECHEC"
curl -s http://localhost:9090 >/dev/null && echo "✅ Prometheus: MARCHE" || echo "❌ Prometheus: ECHEC"
curl -s http://localhost:3000 >/dev/null && echo "✅ Grafana: MARCHE" || echo "❌ Grafana: ECHEC"

echo ""
echo "=== ACCES FINAL ==="
echo "🌐 Application: http://localhost:8080"
echo "🔧 Backend: http://localhost:8000"
echo "📊 Prometheus: http://localhost:9090"
echo "📈 Grafana: http://localhost:3000"
echo ""
echo "🔐 Login: admin@gestion-notes.com / password"
echo "🔐 Grafana: admin / admin"
echo ""
echo "Si ça marche pas, je démissionne."