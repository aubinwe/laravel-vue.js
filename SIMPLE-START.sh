#!/bin/bash

echo "=== DEMARRAGE SIMPLE ==="

# Utiliser docker-compose de base
docker-compose up -d

sleep 60

# Vérifier
echo "=== VERIFICATION ==="
docker-compose ps

echo ""
echo "Tests:"
curl -s http://localhost >/dev/null && echo "Frontend: ✅" || echo "Frontend: ❌"
curl -s http://localhost:8000/api/health >/dev/null && echo "Backend: ✅" || echo "Backend: ❌"

echo ""
echo "=== ACCES ==="
echo "Application: http://localhost"
echo "Backend: http://localhost:8000"

echo ""
echo "Identifiants:"
echo "admin@gestion-notes.com / password"