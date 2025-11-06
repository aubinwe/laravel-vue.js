#!/bin/bash

echo "🚀 SOLUTION INSTANTANÉE"

# Arrêter tout
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# Version ultra-rapide
docker-compose -f docker-compose.minimal.yml up -d

echo "⏳ Attente 30s..."
sleep 30

echo "✅ Test:"
curl http://localhost:8000/api/health

echo "📋 Statut:"
docker ps