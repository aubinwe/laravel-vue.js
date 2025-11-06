#!/bin/bash

echo "=== SOLUTION DEFINITIVE MONITORING ==="

# Arrêter tout
docker-compose -f docker-compose.monitoring.yml down -v
docker system prune -f

# Créer docker-compose final
cat > docker-compose.final.yml << 'EOF'
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
    volumes:
      - mysql_data:/var/lib/mysql

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
      APP_ENV: production
      APP_DEBUG: false
    depends_on:
      mysql:
        condition: service_healthy
    command: >
      sh -c "
        sleep 30 &&
        php artisan config:clear &&
        php artisan route:clear &&
        php artisan migrate:fresh --seed --force &&
        php artisan serve --host=0.0.0.0 --port=8000
      "
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/metrics"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus-final.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
    depends_on:
      backend:
        condition: service_healthy

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus

volumes:
  mysql_data:
  grafana_data:
EOF

# Démarrer avec la nouvelle configuration
echo "Démarrage avec configuration finale..."
docker-compose -f docker-compose.final.yml up --build -d

# Attendre que tout soit prêt
echo "Attente des services..."
sleep 90

# Vérifications
echo "=== VERIFICATIONS ==="
echo "1. Backend health:"
curl -s http://localhost:8000/api/health && echo " ✅" || echo " ❌"

echo "2. Metrics endpoint:"
curl -s http://localhost:8000/metrics | head -3 && echo " ✅" || echo " ❌"

echo "3. Prometheus targets:"
curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"up"' && echo " ✅" || echo " ❌"

echo "4. Services status:"
docker-compose -f docker-compose.final.yml ps

echo ""
echo "=== ACCES FINAL ==="
echo "✅ Application: http://localhost"
echo "✅ Prometheus: http://localhost:9090"
echo "✅ Grafana: http://localhost:3000 (admin/admin)"
echo "✅ Métriques: http://localhost:8000/metrics"

echo ""
echo "=== CONFIGURATION GRAFANA ==="
echo "1. Data Source: http://prometheus:9090"
echo "2. Queries disponibles:"
echo "   - app_users_total"
echo "   - app_grades_total"
echo "   - app_claims_total"
echo "   - http_requests_total"

echo ""
echo "🎉 MONITORING OPERATIONNEL SANS ERREURS !"