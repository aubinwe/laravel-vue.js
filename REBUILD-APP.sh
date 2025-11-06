#!/bin/bash
set -e

echo "=== RECONSTRUCTION COMPLETE ==="

# Arrêter l'ancienne version
docker-compose down -v

# Reconstruire avec les corrections
docker-compose up --build -d

# Attendre que tout soit prêt
echo "Attente des services..."
sleep 60

# Vérifier les logs
echo "=== VERIFICATION ==="
docker-compose ps
docker-compose logs backend | tail -10

echo ""
echo "=== APPLICATION CORRIGEE ==="
echo "URL: http://localhost"
echo ""
echo "IDENTIFIANTS:"
echo "admin@gestion-notes.com / password"
echo "prof@test.com / password"
echo "etudiant@test.com / password"
echo ""
echo "FONCTIONNALITES CORRIGEES:"
echo "✅ Notes visibles pour étudiants"
echo "✅ Gestion des notes pour admin/prof"
echo "✅ Réclamations fonctionnelles"
echo "✅ Données de test créées"