#!/bin/bash

echo "=== REBUILD FRONTEND ==="

# Rebuild frontend avec bonne config
cd frontend
npm run build
cd ..

# Redémarrer frontend
docker stop frontend
docker rm frontend

docker run -d --name frontend \
  -p 8080:80 \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  -v $(pwd)/nginx-working.conf:/etc/nginx/conf.d/default.conf \
  --add-host=host.docker.internal:host-gateway \
  nginx:alpine

echo "Frontend rebuilded avec connexion backend"
echo "Teste sur http://localhost:8080"