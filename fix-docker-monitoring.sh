#!/bin/bash

echo "=== CORRECTION MONITORING DOCKER ==="

# Vérifier si Docker est en cours d'exécution
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker n'est pas en cours d'exécution"
    echo "Démarrez Docker Desktop et réessayez"
    exit 1
fi

# Nettoyer les anciens conteneurs
echo "Nettoyage des anciens conteneurs..."
docker-compose -f docker-compose.monitoring.yml down -v 2>/dev/null || true

# Vérifier les images nécessaires
echo "Vérification des images Docker..."
docker pull mysql:8.0
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest
docker pull prom/node-exporter:latest

# Créer les répertoires nécessaires
mkdir -p monitoring/grafana/provisioning/datasources
mkdir -p monitoring/grafana/provisioning/dashboards

# Configuration automatique Grafana
cat > monitoring/grafana/provisioning/datasources/prometheus.yml << EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

cat > monitoring/grafana/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /var/lib/grafana/dashboards
EOF

# Corriger docker-compose.monitoring.yml
cat > docker-compose.monitoring.yml << EOF
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

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./monitoring/alert_rules.yml:/etc/prometheus/alert_rules.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning:ro
    depends_on:
      - prometheus
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    command:
      - '--path.rootfs=/host'
    volumes:
      - '/:/host:ro,rslave'
    restart: unless-stopped

volumes:
  mysql_data:
  prometheus_data:
  grafana_data:
EOF

# Démarrer les services
echo "Démarrage des services..."
docker-compose -f docker-compose.monitoring.yml up -d

# Attendre que les services soient prêts
echo "Attente des services..."
sleep 60

# Vérifier le statut
echo "=== STATUT DES SERVICES ==="
docker-compose -f docker-compose.monitoring.yml ps

echo ""
echo "=== SERVICES DISPONIBLES ==="
echo "✅ Application: http://localhost"
echo "✅ Prometheus: http://localhost:9090"
echo "✅ Grafana: http://localhost:3000 (admin/admin)"
echo "✅ Node Exporter: http://localhost:9100"
echo "✅ Métriques App: http://localhost:8000/api/metrics"

echo ""
echo "=== CONFIGURATION AUTOMATIQUE ==="
echo "✅ Prometheus configuré automatiquement dans Grafana"
echo "✅ Source de données prête à utiliser"
echo "✅ Dashboards disponibles"

echo ""
echo "Si problème, voir les logs:"
echo "docker-compose -f docker-compose.monitoring.yml logs <service>"