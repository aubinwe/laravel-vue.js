#!/bin/bash

echo "=== CORRECTION ET DÉMARRAGE ==="

# 1. Nettoyer
echo "1. Nettoyage..."
docker-compose down -v
docker system prune -f

# 2. Construire
echo "2. Construction..."
docker-compose build --no-cache

# 3. Démarrer
echo "3. Démarrage..."
docker-compose up -d

# 4. Attendre
echo "4. Attente (60s)..."
sleep 60

# 5. Vérifier
echo "5. Vérification..."
docker-compose ps
docker-compose logs backend | tail -10
docker-compose logs frontend | tail -10

echo "=== ACCÈS ==="
echo "Frontend: http://localhost:5173"
echo "Backend:  http://localhost:8000"
echo "MySQL:    localhost:3306"

# 6. Test connexion
echo "6. Test connexion..."
curl -s http://localhost:5173 > /dev/null && echo "✓ Frontend OK" || echo "✗ Frontend KO"
curl -s http://localhost:8000 > /dev/null && echo "✓ Backend OK" || echo "✗ Backend KO"