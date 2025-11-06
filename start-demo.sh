#!/bin/bash

echo "🚀 Démarrage application Gestion Notes"

# Backend
cd appNotes
echo "📦 Démarrage backend Laravel..."
php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!

# Frontend  
cd ../frontend
echo "🎨 Démarrage frontend Vue.js..."
npm run dev -- --host 0.0.0.0 --port=8080 &
FRONTEND_PID=$!

# Grafana
echo "📊 Démarrage Grafana..."
docker run -d -p 3000:3000 --name grafana-demo grafana/grafana:latest

echo "✅ Application démarrée !"
echo "🌐 Frontend: http://localhost:8080"
echo "⚙️ Backend: http://localhost:8000"
echo "📊 Grafana: http://localhost:3000 (admin/admin)"

echo "Appuyez sur Ctrl+C pour arrêter"
wait