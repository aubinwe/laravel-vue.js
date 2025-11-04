@echo off
echo === RESET DES UTILISATEURS ===

cd appNotes

echo 1. Suppression des utilisateurs existants...
php artisan tinker --execute="App\Models\User::truncate(); App\Models\Role::truncate(); App\Models\Student::truncate();"

echo 2. Recreation des roles et utilisateurs...
php artisan db:seed --class=AdminSeeder

echo 3. Verification...
php artisan tinker --execute="App\Models\User::all()->each(function(\$u) { echo \$u->email . ' - ' . \$u->name . PHP_EOL; });"

echo.
echo === IDENTIFIANTS ===
echo admin@gestion-notes.com / password
echo prof@test.com / password  
echo etudiant@test.com / password
pause