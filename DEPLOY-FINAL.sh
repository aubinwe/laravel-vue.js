#!/bin/bash

echo "🚀 Déploiement DevOps Complet - Gestion Notes"

# 1. Démarrer Docker si nécessaire
sudo service docker start 2>/dev/null || true

# 2. Nettoyer l'environnement
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

# 3. Créer le réseau
docker network create gestion-notes-network 2>/dev/null || true

# 4. MySQL
echo "📦 Démarrage MySQL..."
docker run -d \
  --name mysql \
  --network gestion-notes-network \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=gestion_notes \
  -p 3306:3306 \
  mysql:8.0 --default-authentication-plugin=mysql_native_password

# 5. Attendre MySQL
sleep 30

# 6. Backend
echo "⚙️ Démarrage Backend..."
docker run -d \
  --name backend \
  --network gestion-notes-network \
  -e DB_HOST=mysql \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -p 8000:80 \
  -v $(pwd)/appNotes:/var/www/html \
  php:8.2-apache sh -c "
    apt-get update && apt-get install -y libpng-dev libxml2-dev libzip-dev default-mysql-client &&
    docker-php-ext-install pdo_mysql gd zip &&
    a2enmod rewrite &&
    echo 'DB_CONNECTION=mysql
DB_HOST=mysql
DB_DATABASE=gestion_notes
DB_USERNAME=root
DB_PASSWORD=root
APP_KEY=base64:A1fafHVJb3rrnHwJ9T5nCJoyIoNSRpHFcW7N+Ko9PXw=' > /var/www/html/.env &&
    chown -R www-data:www-data /var/www/html &&
    apache2-foreground
  "

# 7. Attendre Backend
sleep 30

# 8. Initialiser la base
docker exec backend php artisan migrate:fresh --seed --force 2>/dev/null || true

# 9. Frontend
echo "🎨 Démarrage Frontend..."
cd frontend && npm run build && cd ..
docker run -d \
  --name frontend \
  --network gestion-notes-network \
  -p 8080:80 \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  nginx:alpine sh -c "
    echo 'server {
      listen 80;
      root /usr/share/nginx/html;
      index index.html;
      location / { try_files \$uri \$uri/ /index.html; }
      location /api/ {
        proxy_pass http://backend/api/;
        proxy_set_header Host \$host;
      }
    }' > /etc/nginx/conf.d/default.conf &&
    nginx -g 'daemon off;'
  "

# 10. Monitoring
echo "📊 Démarrage Grafana..."
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana:latest

# 11. Résultats
echo ""
echo "✅ Déploiement terminé!"
echo ""
echo "🌐 URLs d'accès:"
echo "   Application: http://localhost:8080"
echo "   Backend API: http://localhost:8000"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "👤 Comptes de test:"
echo "   Admin: admin@gestion-notes.com / password"
echo "   Professeur: prof@test.com / password"
echo "   Étudiant: etudiant@test.com / password"
echo ""
echo "📊 Statut des services:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"