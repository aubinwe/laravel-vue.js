#!/bin/bash

echo "========================================"
echo "   TEST LOCAL (SANS DOCKER)"
echo "========================================"

echo
echo "1. Configuration du backend..."
cd appNotes
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed

echo
echo "2. Démarrage du backend Laravel..."
php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!

echo
echo "3. Attente de 5 secondes..."
sleep 5

echo
echo "4. Test de l'API..."
curl http://localhost:8000/api/health

echo
echo "5. Construction du frontend..."
cd ../frontend
npm install
npm run build

echo
echo "6. Démarrage du frontend..."
npm run dev &
FRONTEND_PID=$!

echo
echo "========================================"
echo "   SERVEURS DÉMARRÉS"
echo "========================================"
echo
echo "Frontend: http://localhost:5173"
echo "Backend API: http://localhost:8000/api"
echo
echo "Comptes de test:"
echo "- admin@gestion-notes.com / password"
echo "- prof@test.com / password"
echo "- etudiant@test.com / password"
echo
echo "Appuyez sur Ctrl+C pour arrêter les serveurs"

# Attendre l'interruption
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait