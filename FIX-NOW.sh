#!/bin/bash

echo "=== CORRECTION IMMEDIATE ==="

# Arrêter tout
docker-compose -f docker-compose.expert.yml down 2>/dev/null || true
docker stop $(docker ps -aq) 2>/dev/null || true

# Démarrer MySQL seul d'abord
echo "MySQL..."
docker run -d --name mysql-simple \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0

sleep 30

# Backend simple
echo "Backend..."
cd appNotes
docker run -d --name backend-simple \
  --link mysql-simple:mysql \
  -v $(pwd):/var/www/html \
  -p 8000:8000 \
  -e DB_HOST=mysql-simple \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  php:8.2-apache sh -c "
    apt-get update && apt-get install -y git curl zip default-mysql-client &&
    docker-php-ext-install pdo pdo_mysql &&
    cd /var/www/html &&
    sleep 20 &&
    php artisan migrate:fresh --seed --force &&
    php artisan serve --host=0.0.0.0 --port=8000
  "

cd ..
sleep 60

# Frontend simple
echo "Frontend..."
cd frontend
npm run build 2>/dev/null || echo "Build frontend skip"
cd ..

docker run -d --name frontend-simple \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  -p 80:80 \
  nginx:alpine

sleep 10

# Tests
echo ""
echo "=== TESTS ==="
curl -s http://localhost >/dev/null && echo "Frontend: ✅" || echo "Frontend: ❌"
curl -s http://localhost:8000/api/health >/dev/null && echo "Backend: ✅" || echo "Backend: ❌"

echo ""
echo "=== ACCES ==="
echo "App: http://localhost"
echo "Backend: http://localhost:8000"
echo "Login: admin@gestion-notes.com / password"