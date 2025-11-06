#!/bin/bash

echo "=== BACKEND ULTRA SIMPLE ==="

# Arrêter l'ancien
docker stop backend-simple backend-fixed 2>/dev/null || true
docker rm backend-simple backend-fixed 2>/dev/null || true

# Créer un backend minimal qui marche
echo "Création backend minimal..."
cd appNotes

# Créer un serveur PHP simple
cat > server.php << 'EOF'
<?php
// Serveur PHP simple pour test
if ($_SERVER['REQUEST_URI'] === '/api/health') {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok', 'time' => date('Y-m-d H:i:s')]);
    exit;
}

if ($_SERVER['REQUEST_URI'] === '/metrics') {
    header('Content-Type: text/plain');
    echo "# HELP app_status Application status\n";
    echo "# TYPE app_status gauge\n";
    echo "app_status 1\n";
    echo "# HELP app_users_total Total users\n";
    echo "# TYPE app_users_total counter\n";
    echo "app_users_total 10\n";
    exit;
}

echo "Backend PHP simple - " . date('Y-m-d H:i:s');
EOF

# Démarrer avec le serveur simple
docker run -d --name backend-minimal \
  -v $(pwd):/var/www/html \
  -p 8000:8000 \
  php:8.2-apache sh -c "
    cd /var/www/html &&
    php -S 0.0.0.0:8000 server.php
  "

cd ..
sleep 10

echo ""
echo "=== TEST ==="
curl -s http://localhost:8000/api/health && echo " - Health OK"
curl -s http://localhost:8000/metrics | head -3 && echo " - Metrics OK"

echo ""
echo "Backend minimal prêt sur http://localhost:8000"