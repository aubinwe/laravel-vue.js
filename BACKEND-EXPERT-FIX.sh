#!/bin/bash

echo "🔧 EXPERT DEVOPS - CORRECTION BACKEND"
echo "====================================="

# 1. DIAGNOSTIC BACKEND
echo "📋 Diagnostic backend..."
docker logs gestionnote-app-1 2>/dev/null | tail -20 || docker logs final-stack-app-1 2>/dev/null | tail -20

# 2. CORRECTION IMMEDIATE
echo "🚨 Correction immédiate du backend..."

# Arrêter le backend défaillant
docker stop gestionnote-app-1 final-stack-app-1 2>/dev/null || true

# 3. BACKEND EXPERT - SOLUTION DEFINITIVE
docker run -d --name backend-expert \
  --network final-stack_default \
  -p 8000:80 \
  -v $(pwd)/appNotes:/var/www/html \
  -e DB_HOST=final-stack-db-1 \
  -e DB_DATABASE=gestion_notes \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root \
  -e APP_KEY=base64:c/U/5irtBb+IP8MfGt+eAyRrrIpg/WxiV/gHCByUOGs= \
  php:8.2-apache bash -c "
    echo '🔧 Configuration Apache...' &&
    apt-get update && apt-get install -y default-mysql-client curl zip unzip git &&
    docker-php-ext-install pdo pdo_mysql &&
    a2enmod rewrite &&
    
    echo '📦 Installation Composer...' &&
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&
    
    cd /var/www/html &&
    echo '🔄 Installation dépendances...' &&
    composer install --no-dev --optimize-autoloader &&
    
    echo '⏳ Attente MySQL...' &&
    until mysql -h final-stack-db-1 -u root -proot -e 'SELECT 1' 2>/dev/null; do
      echo 'Attente MySQL...'
      sleep 5
    done &&
    
    echo '🗄️ Configuration Laravel...' &&
    php artisan config:clear &&
    php artisan cache:clear &&
    
    echo '📊 Migration base...' &&
    php artisan migrate:fresh --seed --force &&
    
    echo '🌐 Démarrage Apache...' &&
    apache2-foreground
  "

# 4. ATTENTE ET VERIFICATION
echo "⏳ Attente démarrage backend (60s)..."
sleep 60

# 5. TESTS EXPERT
echo "🧪 Tests backend expert..."
for i in {1..10}; do
    if curl -f http://localhost:8000 2>/dev/null; then
        echo "✅ Backend opérationnel après ${i}0s"
        break
    fi
    echo "⏳ Test $i/10..."
    sleep 10
done

# 6. VERIFICATION COMPLETE
echo ""
echo "🔍 VERIFICATION COMPLETE"
echo "========================"
curl -I http://localhost:8000 2>/dev/null | head -1 || echo "❌ Backend inaccessible"
curl -s http://localhost:8000/api/health 2>/dev/null && echo "✅ Health check OK" || echo "❌ Health check KO"

# 7. LOGS FINAUX
echo ""
echo "📋 Logs backend (dernières lignes):"
docker logs backend-expert 2>/dev/null | tail -10

echo ""
echo "🎯 BACKEND EXPERT DEPLOYE"
echo "========================="
echo "Backend: http://localhost:8000"
echo "Health: http://localhost:8000/api/health"
echo "Metrics: http://localhost:8000/metrics"
echo ""
echo "Si problème persistant:"
echo "docker logs backend-expert"