#!/bin/bash

echo "=== BACKEND DIRECT ==="

# Arrêter le backend actuel
docker stop gestionnote-backend-1 2>/dev/null || true
docker rm gestionnote-backend-1 2>/dev/null || true

# Démarrer MySQL si pas déjà fait
docker start gestionnote-mysql-1 2>/dev/null || echo "MySQL déjà démarré"

# Attendre MySQL
sleep 10

# Démarrer backend directement
echo "Démarrage backend direct..."
cd appNotes

docker run -d --name backend-direct \
  --network gestionnote_default \
  -e DB_HOST=gestionnote-mysql-1 \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  -p 8000:8000 \
  gestionnote-backend \
  sh -c "
    echo 'Attente MySQL...' &&
    sleep 30 &&
    echo 'Migration...' &&
    php artisan migrate:fresh --seed --force &&
    echo 'Démarrage serveur...' &&
    php artisan serve --host=0.0.0.0 --port=8000
  "

cd ..

# Suivre les logs
echo "Logs du backend:"
docker logs -f backend-direct &
LOGS_PID=$!

# Attendre et tester
sleep 60
kill $LOGS_PID 2>/dev/null

echo ""
echo "=== TEST ==="
curl -s http://localhost:8000/api/health
curl -s http://localhost:8000/api/metrics | head -3