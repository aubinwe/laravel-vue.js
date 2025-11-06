#!/bin/bash

echo "Test rapide de l'application..."

# Backend
echo "1. Démarrage du backend..."
cd appNotes
php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!

sleep 3

# Test API
echo "2. Test de l'API..."
curl http://localhost:8000/api/health

echo
echo "3. Backend démarré sur http://localhost:8000"
echo "   Ouvrez un autre terminal et lancez:"
echo "   cd frontend && npm run dev"
echo
echo "   Puis accédez à http://localhost:5173"
echo
echo "Appuyez sur Ctrl+C pour arrêter le backend"

trap "kill $BACKEND_PID; exit" INT
wait