#!/bin/bash

echo "=== CORRECTION URGENTE ==="

# Vérifier les conteneurs
echo "Conteneurs actuels:"
docker ps -a

# Redémarrer le backend
echo "Redémarrage backend..."
docker restart backend 2>/dev/null || docker restart gestionnote-backend-1 2>/dev/null || echo "Backend non trouvé"

# Si pas de backend, le créer
if ! docker ps | grep -q backend; then
    echo "Création nouveau backend..."
    docker run -d --name backend-fix \
      -e DB_HOST=mysql \
      -e DB_DATABASE=gestion_notes \
      -e DB_USERNAME=root \
      -e DB_PASSWORD=root \
      -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
      -p 8000:8000 \
      --link mysql:mysql \
      php:8.2-apache sh -c "
        apt-get update && apt-get install -y git curl zip unzip default-mysql-client &&
        docker-php-ext-install pdo pdo_mysql &&
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
        git clone https://github.com/laravel/laravel.git /var/www/html || echo 'Skip clone' &&
        cd /var/www/html &&
        echo 'APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs=' > .env &&
        echo 'DB_HOST=mysql' >> .env &&
        echo 'DB_DATABASE=gestion_notes' >> .env &&
        echo 'DB_USERNAME=root' >> .env &&
        echo 'DB_PASSWORD=root' >> .env &&
        php artisan serve --host=0.0.0.0 --port=8000
      "
fi

sleep 30

# Test backend
echo "Test backend:"
curl -v http://localhost:8000 2>&1 | head -10

# Redémarrer prometheus et grafana
echo "Redémarrage monitoring..."
docker restart prometheus 2>/dev/null || docker restart gestionnote-prometheus-1 2>/dev/null
docker restart grafana 2>/dev/null || docker restart gestionnote-grafana-1 2>/dev/null

sleep 10

echo ""
echo "=== TESTS ==="
echo "Backend: $(curl -s http://localhost:8000 >/dev/null && echo '✅' || echo '❌')"
echo "Prometheus: $(curl -s http://localhost:9090 >/dev/null && echo '✅' || echo '❌')"
echo "Grafana: $(curl -s http://localhost:3000 >/dev/null && echo '✅' || echo '❌')"

echo ""
echo "=== ACCES ==="
echo "App: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"