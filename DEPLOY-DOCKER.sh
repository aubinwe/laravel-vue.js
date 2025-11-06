#!/bin/bash

echo "=== DEPLOIEMENT DOCKER PRODUCTION ==="

# 1. Nettoyer Docker
docker logout
docker system prune -af
docker volume prune -f

# 2. Login Docker (si nécessaire)
echo "Login Docker Hub..."
docker login

# 3. Pull des images de base
echo "Pull des images de base..."
docker pull node:18-alpine
docker pull nginx:alpine
docker pull php:8.2-apache
docker pull composer:latest
docker pull mysql:8.0
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest

# 4. Build et démarrage
echo "Build et démarrage..."
DOCKER_BUILDKIT=0 docker-compose -f docker-compose.production.yml up --build -d

# 5. Attendre les services
echo "Attente des services (3 minutes)..."
sleep 180

# 6. Vérifications
echo ""
echo "=== VERIFICATIONS ==="
docker-compose -f docker-compose.production.yml ps

echo ""
echo "Tests de connectivité:"
curl -s http://localhost >/dev/null && echo "Frontend: ✅" || echo "Frontend: ❌"
curl -s http://localhost:8000/api/health >/dev/null && echo "Backend: ✅" || echo "Backend: ❌"
curl -s http://localhost:8000/metrics >/dev/null && echo "Metrics: ✅" || echo "Metrics: ❌"
curl -s http://localhost:9090 >/dev/null && echo "Prometheus: ✅" || echo "Prometheus: ❌"
curl -s http://localhost:3000 >/dev/null && echo "Grafana: ✅" || echo "Grafana: ❌"

echo ""
echo "=== ACCES ==="
echo "Application: http://localhost"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"
echo ""
echo "Login Grafana: admin/admin"
echo "Login App: admin@gestion-notes.com/password"

echo ""
echo "=== LOGS EN CAS DE PROBLEME ==="
echo "docker-compose -f docker-compose.production.yml logs backend"
echo "docker-compose -f docker-compose.production.yml logs frontend"