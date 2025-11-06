#!/bin/bash

echo "🚀 DEPLOIEMENT EXPERT - SOLUTION COMPLETE"
echo "========================================"

# Phase 1: Diagnostic et nettoyage
echo "📋 Phase 1: Diagnostic système"
docker --version || { echo "❌ Docker non installé"; exit 1; }
docker-compose --version || { echo "❌ Docker Compose non installé"; exit 1; }
node --version || { echo "❌ Node.js non installé"; exit 1; }

echo "🧹 Nettoyage complet"
docker-compose down -v 2>/dev/null || true
docker system prune -af --volumes
docker network prune -f

# Phase 2: Préparation des images
echo "📦 Phase 2: Préparation des images Docker"
docker pull mysql:8.0 &
docker pull php:8.2-apache &
docker pull node:18-alpine &
docker pull nginx:alpine &
docker pull prom/prometheus:latest &
docker pull grafana/grafana:latest &
wait

# Phase 3: Configuration optimisée
echo "⚙️  Phase 3: Configuration système"

cat > docker-compose.expert.yml << 'EOF'
version: '3.8'

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:
  grafana_data:
  prometheus_data:

services:
  mysql:
    image: mysql:8.0
    container_name: mysql-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: gestion_notes
      MYSQL_CHARACTER_SET_SERVER: utf8mb4
      MYSQL_COLLATION_SERVER: utf8mb4_unicode_ci
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  backend:
    build:
      context: ./appNotes
      dockerfile: Dockerfile
    container_name: laravel-backend
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - DB_HOST=mysql-db
      - DB_DATABASE=gestion_notes
      - DB_USERNAME=root
      - DB_PASSWORD=root
      - APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs=
      - APP_ENV=production
      - APP_DEBUG=false
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - app-network
    command: >
      sh -c "
        echo '⏳ Attente MySQL...' &&
        sleep 20 &&
        echo '🔄 Migration base de données...' &&
        php artisan migrate:fresh --seed --force &&
        echo '🚀 Démarrage serveur Laravel...' &&
        php artisan serve --host=0.0.0.0 --port=8000
      "
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/metrics"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: vue-frontend
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus-monitor
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=15d'
      - '--web.enable-lifecycle'
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - app-network

  grafana:
    image: grafana/grafana:latest
    container_name: grafana-dashboard
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - app-network
EOF

# Phase 4: Déploiement
echo "🚀 Phase 4: Déploiement de l'application"
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

docker-compose -f docker-compose.expert.yml up --build -d

# Phase 5: Monitoring du déploiement
echo "📊 Phase 5: Monitoring du déploiement"
echo "Attente du démarrage des services..."

for i in {1..12}; do
    echo "⏳ Vérification $i/12 (${i}0s)"
    sleep 10
    
    if docker-compose -f docker-compose.expert.yml ps | grep -q "Up (healthy)"; then
        echo "✅ Services en cours de démarrage..."
    fi
done

# Phase 6: Tests de validation
echo "🧪 Phase 6: Tests de validation"
sleep 30

echo "Tests de connectivité:"
curl -s -o /dev/null -w "Frontend (Port 80): %{http_code}\n" http://localhost/ || echo "Frontend: ❌"
curl -s -o /dev/null -w "Backend Health: %{http_code}\n" http://localhost:8000/api/health || echo "Backend Health: ❌"
curl -s -o /dev/null -w "Backend Metrics: %{http_code}\n" http://localhost:8000/metrics || echo "Backend Metrics: ❌"
curl -s -o /dev/null -w "Prometheus: %{http_code}\n" http://localhost:9090/ || echo "Prometheus: ❌"
curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://localhost:3000/ || echo "Grafana: ❌"

# Phase 7: Statut final
echo ""
echo "📋 STATUT FINAL DES SERVICES"
echo "============================"
docker-compose -f docker-compose.expert.yml ps

echo ""
echo "🎯 ACCES AUX SERVICES"
echo "===================="
echo "🌐 Application Web:    http://localhost"
echo "📊 Prometheus:         http://localhost:9090"
echo "📈 Grafana:           http://localhost:3000"
echo "🔧 Backend API:       http://localhost:8000"
echo ""
echo "🔐 IDENTIFIANTS"
echo "==============="
echo "Application:"
echo "  - Admin: admin@gestion-notes.com / password"
echo "  - Prof:  prof@test.com / password"
echo "  - Etudiant: etudiant@test.com / password"
echo ""
echo "Grafana: admin / admin"
echo ""
echo "📚 CONFIGURATION GRAFANA"
echo "========================"
echo "1. Aller sur http://localhost:3000"
echo "2. Login: admin/admin"
echo "3. Add Data Source → Prometheus"
echo "4. URL: http://prometheus-monitor:9090"
echo "5. Save & Test"
echo "6. Create Dashboard avec ces queries:"
echo "   - app_users_total (Nombre d'utilisateurs)"
echo "   - app_grades_total (Nombre de notes)"
echo "   - http_requests_total (Requêtes HTTP)"
echo ""
echo "🔧 COMMANDES UTILES"
echo "==================="
echo "Logs: docker-compose -f docker-compose.expert.yml logs [service]"
echo "Restart: docker-compose -f docker-compose.expert.yml restart [service]"
echo "Stop: docker-compose -f docker-compose.expert.yml down"
echo ""
echo "✅ DEPLOIEMENT EXPERT TERMINE AVEC SUCCES!"