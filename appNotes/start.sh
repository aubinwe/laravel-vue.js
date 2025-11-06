#!/bin/sh

echo "Attente de la base de données..."
until nc -z mysql-service 3306; do
  echo "En attente de MySQL..."
  sleep 5
done
echo "MySQL est prêt!"

# Attendre encore un peu pour être sûr
sleep 10

echo "Configuration de l'application..."
php artisan config:cache

echo "Exécution des migrations..."
php artisan migrate --force

echo "Exécution des seeders..."
php artisan db:seed --force

echo "Optimisation pour la production..."
php artisan route:cache
php artisan view:cache

echo "Vérification des utilisateurs créés..."
php artisan tinker --execute="echo 'Utilisateurs créés: ' . App\Models\User::count() . PHP_EOL;"

echo "Démarrage du serveur..."
php artisan serve --host=0.0.0.0 --port=8000