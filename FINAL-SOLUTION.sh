#!/bin/bash

echo "=== SOLUTION FINALE ==="

# Arrêter TOUS les conteneurs
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# Stack avec ports libres
cat > final-stack.yml << 'EOF'
version: '3.8'
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: gestion_notes
    ports:
      - "3306:3306"
    healthcheck:
      test: mysqladmin ping -h localhost
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    image: php:8.2-apache
    ports:
      - "8000:80"
    volumes:
      - ./appNotes:/var/www/html
    environment:
      DB_HOST: db
      DB_DATABASE: gestion_notes
      DB_USERNAME: root
      DB_PASSWORD: root
    depends_on:
      db:
        condition: service_healthy
    command: >
      bash -c "
        apt-get update && apt-get install -y default-mysql-client curl &&
        docker-php-ext-install pdo pdo_mysql &&
        a2enmod rewrite &&
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
        cd /var/www/html &&
        composer install --no-dev &&
        sleep 15 &&
        php artisan migrate:fresh --seed --force &&
        apache2-foreground
      "

  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html
      - ./nginx-final.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus-final.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
EOF

# Configuration nginx
cat > nginx-final.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://app:80/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Configuration prometheus
cat > prometheus-final.yml << 'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:80']
    metrics_path: '/metrics'
EOF

# Build frontend
cd frontend
npm run build
cd ..

# Démarrage
docker-compose -f final-stack.yml up -d

# Attente
sleep 90

# Tests
echo ""
echo "=== TESTS ==="
curl -s http://localhost:8080 >/dev/null && echo "Frontend: ✅" || echo "Frontend: ❌"
curl -s http://localhost:8000 >/dev/null && echo "Backend: ✅" || echo "Backend: ❌"
curl -s http://localhost:9090 >/dev/null && echo "Prometheus: ✅" || echo "Prometheus: ❌"
curl -s http://localhost:3000 >/dev/null && echo "Grafana: ✅" || echo "Grafana: ❌"

echo ""
echo "=== ACCES ==="
echo "Application: http://localhost:8080"
echo "Backend: http://localhost:8000"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"
echo ""
echo "Login: admin@gestion-notes.com / password"