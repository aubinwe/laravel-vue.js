#!/bin/bash

echo "=== CORRECTION CONNEXION ==="

# Arrêter le frontend
docker stop frontend
docker rm frontend

# Créer nginx.conf qui marche
cat > nginx-working.conf << 'EOF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://host.docker.internal:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# Redémarrer frontend avec bonne config
docker run -d --name frontend \
  -p 8080:80 \
  -v $(pwd)/frontend/dist:/usr/share/nginx/html \
  -v $(pwd)/nginx-working.conf:/etc/nginx/conf.d/default.conf \
  --add-host=host.docker.internal:host-gateway \
  nginx:alpine

sleep 10

# Test connexion
echo "Test connexion frontend -> backend:"
docker exec frontend wget -qO- http://host.docker.internal:8000/api/health 2>/dev/null && echo "✅ Connexion OK" || echo "❌ Connexion KO"

echo ""
echo "Maintenant teste la connexion sur http://localhost:8080"