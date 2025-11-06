#!/bin/bash

echo "=== DIAGNOSTIC URGENT ==="

# 1. Statut des conteneurs
echo "1. CONTENEURS:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Logs des services
echo ""
echo "2. LOGS BACKEND:"
docker logs laravel-backend 2>/dev/null | tail -10 || echo "Backend non trouvé"

echo ""
echo "3. LOGS FRONTEND:"
docker logs vue-frontend 2>/dev/null | tail -10 || echo "Frontend non trouvé"

# 4. Tests de connectivité
echo ""
echo "4. TESTS:"
curl -I http://localhost 2>/dev/null | head -1 || echo "Frontend: INACCESSIBLE"
curl -I http://localhost:8000 2>/dev/null | head -1 || echo "Backend: INACCESSIBLE"
curl -I http://localhost:9090 2>/dev/null | head -1 || echo "Prometheus: INACCESSIBLE"
curl -I http://localhost:3000 2>/dev/null | head -1 || echo "Grafana: INACCESSIBLE"

# 5. Ports utilisés
echo ""
echo "5. PORTS UTILISES:"
netstat -tulpn 2>/dev/null | grep -E ":80|:8000|:9090|:3000" || ss -tulpn | grep -E ":80|:8000|:9090|:3000"

echo ""
echo "=== SOLUTION IMMEDIATE ==="
echo "docker-compose -f docker-compose.expert.yml restart"
echo "ou"
echo "./FIX-NOW.sh"