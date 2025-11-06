#!/bin/bash

echo "=== CORRECTION BACKEND ==="

# Voir les logs du backend
echo "Logs backend:"
docker logs backend-simple

# Arrêter le backend défaillant
docker stop backend-simple
docker rm backend-simple

# Redémarrer avec plus de temps et debug
echo "Redémarrage backend avec debug..."
cd appNotes

docker run -d --name backend-fixed \
  --link mysql-simple:mysql \
  -v $(pwd):/var/www/html \
  -p 8000:8000 \
  -e DB_HOST=mysql-simple \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  php:8.2-apache sh -c "
    echo 'Installation dépendances...' &&
    apt-get update && apt-get install -y git curl zip default-mysql-client &&
    docker-php-ext-install pdo pdo_mysql &&
    cd /var/www/html &&
    echo 'Attente MySQL...' &&
    sleep 60 &&
    echo 'Test connexion MySQL...' &&
    mysql -h mysql-simple -u root -proot -e 'SELECT 1' &&
    echo 'Migration...' &&
    php artisan migrate:fresh --seed --force &&
    echo 'Démarrage serveur...' &&
    php artisan serve --host=0.0.0.0 --port=8000
  "

cd ..

# Suivre les logs en temps réel
echo "Suivi des logs (Ctrl+C pour arrêter):"
docker logs -f backend-fixed &
LOGS_PID=$!

# Attendre et tester
sleep 90
kill $LOGS_PID 2>/dev/null

echo ""
echo "=== TEST BACKEND ==="
curl -v http://localhost:8000/api/health 2>&1 | head -10
curl -s http://localhost:8000/metrics | head -3

echo ""
echo "Si ça marche pas, voir les logs:"
echo "docker logs backend-fixed"