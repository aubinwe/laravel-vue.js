#!/bin/bash

echo "=== DEMARRAGE APPLICATION ==="

# Arrêter les anciens conteneurs
docker-compose down -v

# Construire et démarrer
docker-compose up --build -d

# Attendre que tout soit prêt
echo "Attente des services..."
sleep 30

# Vérifier les services
echo "=== VERIFICATION ==="
docker-compose ps

echo ""
echo "=== APPLICATION PRETE ==="
echo "URL: http://localhost"
echo ""
echo "IDENTIFIANTS:"
echo "- Admin: admin@gestion-notes.com / password"
echo "- Professeur: prof@test.com / password"
echo "- Etudiant: etudiant@test.com / password"
echo ""
echo "Pour voir les logs:"
echo "docker-compose logs -f"