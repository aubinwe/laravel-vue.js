#!/bin/bash
set -e

echo "=== CORRECTION FINALE ==="

# Arrêter tout
docker-compose down -v
docker system prune -f

# Reconstruire complètement
docker-compose up --build -d

# Attendre
echo "Attente des services..."
sleep 90

# Vérifier
echo "=== VERIFICATION ==="
docker-compose ps

# Test API
echo "Test API..."
curl -s http://localhost:8000/api/health && echo " - Backend OK" || echo " - Backend KO"

echo ""
echo "=== APPLICATION FINALE ==="
echo "URL: http://localhost"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"
echo ""
echo "Si problème, voir logs:"
echo "docker-compose logs backend"