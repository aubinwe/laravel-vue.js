@echo off
echo === DIAGNOSTIC CONNEXION ===

echo 1. Test phpMyAdmin...
start http://localhost/phpmyadmin
timeout /t 3

echo 2. Test connexion directe...
php -r "try { \$pdo = new PDO('mysql:host=127.0.0.1', 'root', ''); echo 'MySQL OK sans mot de passe\n'; } catch(Exception \$e) { echo 'Erreur: ' . \$e->getMessage() . '\n'; }"

echo 3. Test avec mot de passe...
php -r "try { \$pdo = new PDO('mysql:host=127.0.0.1', 'root', 'root'); echo 'MySQL OK avec mot de passe root\n'; } catch(Exception \$e) { echo 'Erreur: ' . \$e->getMessage() . '\n'; }"

echo 4. Configuration Laravel...
cd appNotes
php artisan config:clear
php artisan cache:clear

echo 5. Test Laravel DB...
php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'Laravel DB: OK\n'; } catch(Exception \$e) { echo 'Laravel DB Erreur: ' . \$e->getMessage() . '\n'; }"

pause