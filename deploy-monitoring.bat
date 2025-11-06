@echo off
echo === DEPLOIEMENT AVEC MONITORING ===

echo Demarrage de l'application complete...
docker-compose up -d

echo Verification des services...
docker-compose ps

echo === SERVICES DISPONIBLES ===
echo Application: http://localhost
echo Prometheus: http://localhost:9090
echo Grafana: http://localhost:3000 (admin/admin)
echo Backend API: http://localhost:8000

start http://localhost
start http://localhost:3000
pause