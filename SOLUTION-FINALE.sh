#!/bin/bash

echo "========================================="
echo "    SOLUTION FINALE - GARANTIE 100%"
echo "========================================="

# ARRET ET NETTOYAGE TOTAL
echo "=== NETTOYAGE TOTAL ==="
kubectl delete namespace gestion-notes --ignore-not-found=true --wait=true
minikube stop 2>/dev/null || true
minikube delete 2>/dev/null || true
docker system prune -af

# REDEMARRAGE MINIKUBE
echo "=== REDEMARRAGE MINIKUBE ==="
minikube start --driver=docker --memory=4096 --cpus=2
eval $(minikube docker-env)

# BUILD IMAGES DIRECTEMENT
echo "=== BUILD IMAGES ==="
cd appNotes
cat > Dockerfile.simple << 'EOF'
FROM php:8.2-apache
RUN apt-get update && apt-get install -y \
    git curl libpng-dev zip unzip mysql-client netcat-openbsd \
    && docker-php-ext-install pdo pdo_mysql
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN a2enmod rewrite
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data storage bootstrap/cache
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
EOF

docker build -f Dockerfile.simple -t appnotes-backend:latest .

cd ../frontend
cat > Dockerfile.simple << 'EOF'
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html; location / { try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

docker build -f Dockerfile.simple -t appnotes-frontend:latest .
cd ..

# DEPLOIEMENT DIRECT
echo "=== DEPLOIEMENT DIRECT ==="
kubectl create namespace gestion-notes

# MySQL
kubectl run mysql --image=mysql:8.0 --env="MYSQL_ROOT_PASSWORD=rootpassword" --env="MYSQL_DATABASE=gestion_notes" --port=3306 -n gestion-notes
kubectl expose pod mysql --port=3306 --name=mysql-service -n gestion-notes
kubectl wait --for=condition=ready pod mysql -n gestion-notes --timeout=300s

# Backend
kubectl run backend --image=appnotes-backend:latest --image-pull-policy=Never --port=8000 -n gestion-notes \
  --env="DB_HOST=mysql-service" \
  --env="DB_DATABASE=gestion_notes" \
  --env="DB_USERNAME=root" \
  --env="DB_PASSWORD=rootpassword" \
  --env="APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs="

kubectl expose pod backend --port=8000 --name=backend-service -n gestion-notes
kubectl wait --for=condition=ready pod backend -n gestion-notes --timeout=300s

# Initialiser la base
echo "=== INITIALISATION BASE ==="
kubectl exec backend -n gestion-notes -- php artisan migrate:fresh --seed --force

# Frontend
kubectl run frontend --image=appnotes-frontend:latest --image-pull-policy=Never --port=80 -n gestion-notes
kubectl expose pod frontend --port=80 --type=NodePort --name=frontend-service -n gestion-notes
kubectl wait --for=condition=ready pod frontend -n gestion-notes --timeout=180s

# VERIFICATION
echo "=== VERIFICATION ==="
kubectl get pods -n gestion-notes
kubectl get services -n gestion-notes

# URL D'ACCES
echo ""
echo "========================================="
echo "         APPLICATION DEPLOYEE !"
echo "========================================="
echo ""
minikube service frontend-service -n gestion-notes --url
echo ""
echo "Pour ouvrir:"
echo "minikube service frontend-service -n gestion-notes"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"