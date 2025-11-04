#!/bin/sh

echo "Attente de la base de données..."
until nc -z mysql-service 3306; do
  echo "En attente de MySQL..."
  sleep 5
done
echo "MySQL est prêt!"

echo "Génération de la clé d'application..."
php artisan key:generate --force

echo "Exécution des migrations..."
php artisan migrate:fresh --force

echo "Exécution des seeders..."
php artisan db:seed --force

echo "Vérification des utilisateurs créés..."
php artisan tinker --execute="echo 'Utilisateurs:'; App\Models\User::all(['name', 'email'])->each(function(\$u) { echo \$u->name . ' - ' . \$u->email . PHP_EOL; });"

echo "Démarrage du serveur..."
php artisan serve --host=0.0.0.0 --port=8000