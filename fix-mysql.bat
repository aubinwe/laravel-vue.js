@echo off
echo === CORRECTION MYSQL ===

echo 1. Arret des conteneurs Docker...
docker stop $(docker ps -q) 2>nul

echo 2. Verification XAMPP MySQL...
net start | findstr MySQL >nul && echo "MySQL XAMPP: Running" || echo "MySQL XAMPP: Stopped - Demarrer XAMPP"

echo 3. Test de connexion...
mysql -u root -p -e "SHOW DATABASES;" 2>nul && echo "Connexion: OK" || echo "Connexion: KO"

echo 4. Creation de la base si necessaire...
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS gestion_notes;"

echo 5. Reset des utilisateurs avec Artisan...
cd appNotes
php artisan config:clear
php artisan migrate:fresh --seed

pause