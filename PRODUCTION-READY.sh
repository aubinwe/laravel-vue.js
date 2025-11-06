#!/bin/bash

# SOLUTION DEVOPS DEFINITIVE
# Auteur: Expert DevOps
# Objectif: Déploiement production sans faille

set -e  # Arrêt immédiat en cas d'erreur

echo "🚀 DEPLOIEMENT PRODUCTION DEVOPS"
echo "================================="

# 1. NETTOYAGE RADICAL
docker system prune -af --volumes
docker network prune -f

# 2. CREATION STACK COMPLETE
cat > stack.yml << 'EOF'
version: '3.8'
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: gestion_notes
    volumes:
      - db_data:/var/lib/mysql
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
        apt-get update && apt-get install -y default-mysql-client &&
        docker-php-ext-install pdo pdo_mysql &&
        a2enmod rewrite &&
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
        cd /var/www/html &&
        composer install --no-dev &&
        sleep 10 &&
        php artisan migrate:fresh --seed --force &&
        apache2-foreground
      "

  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin

volumes:
  db_data:
EOF

# 3. CONFIGURATION NGINX
cat > nginx.conf << 'EOF'
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

# 4. CONFIGURATION PROMETHEUS
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:80']
    metrics_path: '/metrics'
EOF

# 5. BUILD FRONTEND
cd frontend
npm install && npm run build
cd ..

# 6. DEPLOIEMENT
docker-compose -f stack.yml up -d

# 7. ATTENTE SERVICES
echo "⏳ Attente services (60s)..."
sleep 60

# 8. VERIFICATION
echo "✅ VERIFICATION SERVICES"
curl -f http://localhost || echo "❌ Frontend KO"
curl -f http://localhost:8000 || echo "❌ Backend KO"
curl -f http://localhost:9090 || echo "❌ Prometheus KO"
curl -f http://localhost:3000 || echo "❌ Grafana KO"

echo ""
echo "🎯 ACCES PRODUCTION"
echo "Frontend: http://localhost"
echo "Backend: http://localhost:8000"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "Login: admin@gestion-notes.com / password"
echo ""
echo "✅ DEPLOIEMENT TERMINE"