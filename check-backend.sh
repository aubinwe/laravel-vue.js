#!/bin/bash

echo "=== DIAGNOSTIC BACKEND ==="

# Vérifier si le backend tourne
echo "1. Statut conteneur backend:"
docker ps | grep backend || echo "Backend non trouvé"

# Vérifier les logs
echo "2. Logs backend:"
docker logs backend 2>/dev/null | tail -10 || echo "Pas de logs backend"

# Test direct
echo "3. Test direct:"
curl -v http://localhost:8000/api/health 2>&1 | head -10

# Test metrics
echo "4. Test metrics:"
curl -v http://localhost:8000/api/metrics 2>&1 | head -5

# Vérifier les processus dans le conteneur
echo "5. Processus dans le conteneur:"
docker exec backend ps aux 2>/dev/null || echo "Impossible d'accéder au conteneur"

echo ""
echo "=== SOLUTION ==="
echo "Si le backend ne répond pas:"
echo "docker restart backend"
echo "ou"
echo "./SIMPLE-MONITORING.sh"