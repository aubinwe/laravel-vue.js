#!/bin/bash
set -e

echo "=== CORRECTION ET DEPLOIEMENT ==="

# Publier les migrations Sanctum
cd appNotes
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
cd ..

# Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'
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
    build: ./appNotes
    ports:
      - "8000:8000"
    environment:
      DB_HOST: mysql
      DB_DATABASE: gestion_notes
      DB_USERNAME: root
      DB_PASSWORD: root
      APP_KEY: base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs=
    depends_on:
      mysql:
        condition: service_healthy
    command: >
      sh -c "
        sleep 30 &&
        php artisan migrate:fresh --force &&
        php artisan db:seed --force &&
        php artisan serve --host=0.0.0.0 --port=8000
      "

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
EOF

# Démarrer
docker-compose down -v
docker-compose up --build -d

# Attendre
sleep 60

# Vérifier
docker-compose ps

echo ""
echo "=== APPLICATION PRETE ==="
echo "URL: http://localhost"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"
echo ""
echo "Pour voir les logs:"
echo "docker-compose logs backend"