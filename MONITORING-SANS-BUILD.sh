#!/bin/bash

echo "=== MONITORING SANS BUILD ==="

# Arrêter tout
docker-compose down -v 2>/dev/null || true

# Utiliser des images pré-construites
cat > docker-compose.nobuild.yml << 'EOF'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: gestion_notes
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  backend:
    image: php:8.2-apache
    ports:
      - "8000:8000"
    environment:
      DB_HOST: mysql
      DB_DATABASE: gestion_notes
      DB_USERNAME: root
      DB_PASSWORD: root
    volumes:
      - ./appNotes:/var/www/html
    depends_on:
      mysql:
        condition: service_healthy
    command: >
      sh -c "
        apt-get update && apt-get install -y git curl libpng-dev zip unzip default-mysql-client &&
        docker-php-ext-install pdo pdo_mysql &&
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
        cd /var/www/html &&
        composer install --no-dev --optimize-autoloader &&
        sleep 30 &&
        php artisan migrate:fresh --seed --force &&
        php artisan serve --host=0.0.0.0 --port=8000
      "

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus-final.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html
      - ./nginx-simple.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend
EOF

# Créer config nginx simple
cat > nginx-simple.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host $host;
    }
}
EOF

# Build frontend localement
echo "Build frontend local..."
cd frontend
npm install
npm run build
cd ..

# Démarrer sans build Docker
echo "Démarrage sans build Docker..."
docker-compose -f docker-compose.nobuild.yml up -d

# Attendre
sleep 90

echo ""
echo "=== SERVICES ==="
echo "App: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Backend: http://localhost:8000/metrics"