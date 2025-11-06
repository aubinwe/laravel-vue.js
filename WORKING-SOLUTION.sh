#!/bin/bash

# SOLUTION QUI MARCHE - POINT FINAL
docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

# 1. MySQL
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=gestion_notes -p 3306:3306 mysql:8.0
sleep 30

# 2. Backend qui marche
cd appNotes
docker run -d --name backend --link mysql:mysql -p 8000:8000 -v $(pwd):/app -w /app php:8.2-cli sh -c "
apt-get update && apt-get install -y default-mysql-client &&
docker-php-ext-install pdo pdo_mysql &&
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
composer install --no-dev &&
sleep 20 &&
php artisan migrate:fresh --seed --force &&
php -S 0.0.0.0:8000 -t public
"
cd ..

sleep 60

# 3. Frontend
docker run -d --name frontend -p 8080:80 -v $(pwd)/frontend/dist:/usr/share/nginx/html nginx:alpine

# 4. Monitoring
docker run -d --name prometheus --link backend:backend -p 9090:9090 -v $(pwd)/prometheus-final.yml:/etc/prometheus/prometheus.yml prom/prometheus:latest
docker run -d --name grafana -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana:latest

sleep 20

# Tests
curl -f http://localhost:8080 && echo "Frontend: OK" || echo "Frontend: KO"
curl -f http://localhost:8000 && echo "Backend: OK" || echo "Backend: KO"
curl -f http://localhost:9090 && echo "Prometheus: OK" || echo "Prometheus: KO"
curl -f http://localhost:3000 && echo "Grafana: OK" || echo "Grafana: KO"

echo ""
echo "ACCES:"
echo "App: http://localhost:8080"
echo "Backend: http://localhost:8000"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"