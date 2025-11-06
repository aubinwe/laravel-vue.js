#!/bin/bash

echo "=== TEST DEVOPS SIMPLE ==="

# 1. Test Docker Compose
echo "1. Test Docker Compose..."
docker-compose -f docker-compose.simple.yml up -d
sleep 30
echo "✓ Services démarrés"

# 2. Test accès
echo "2. Test accès..."
curl -s http://localhost:5173 > /dev/null && echo "✓ Frontend OK" || echo "✗ Frontend KO"
curl -s http://localhost:8000 > /dev/null && echo "✓ Backend OK" || echo "✗ Backend KO"

# 3. Arrêt
echo "3. Arrêt des services..."
docker-compose -f docker-compose.simple.yml down

echo "=== TEST TERMINÉ ==="