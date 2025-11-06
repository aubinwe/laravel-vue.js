#!/bin/bash

echo "=== DEPLOIEMENT FINAL FONCTIONNEL ==="

# 1. Nettoyer complètement
docker-compose down -v
docker system prune -f

# 2. Créer docker-compose qui marche
cat > docker-compose.working.yml << 'EOF'
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
        php artisan migrate:fresh --seed --force &&
        php artisan serve --host=0.0.0.0 --port=8000
      "

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
      - ./monitoring/prometheus-working.yml:/etc/prometheus/prometheus.yml
    depends_on:
      - backend

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
EOF

# 3. Configuration Prometheus qui marche
cat > monitoring/prometheus-working.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
    scrape_interval: 30s
EOF

# 4. Démarrer
docker-compose -f docker-compose.working.yml up --build -d

# 5. Attendre
echo "Attente des services (2 minutes)..."
sleep 120

# 6. Vérifications
echo "=== VERIFICATIONS ==="
echo "App: $(curl -s http://localhost >/dev/null && echo '✅ OK' || echo '❌ KO')"
echo "Backend: $(curl -s http://localhost:8000/api/health >/dev/null && echo '✅ OK' || echo '❌ KO')"
echo "Metrics: $(curl -s http://localhost:8000/metrics >/dev/null && echo '✅ OK' || echo '❌ KO')"
echo "Prometheus: $(curl -s http://localhost:9090 >/dev/null && echo '✅ OK' || echo '❌ KO')"
echo "Grafana: $(curl -s http://localhost:3000 >/dev/null && echo '✅ OK' || echo '❌ KO')"

echo ""
echo "=== ACCES ==="
echo "Application: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"

echo ""
echo "=== IDENTIFIANTS APP ==="
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"

echo ""
echo "=== CONFIGURATION GRAFANA ==="
echo "1. Aller sur http://localhost:3000"
echo "2. Login: admin/admin"
echo "3. Add data source: Prometheus"
echo "4. URL: http://prometheus:9090"
echo "5. Save & Test"
echo "6. Create dashboard avec query: app_users_total"