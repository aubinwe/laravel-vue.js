@echo off
echo === TEST DES IDENTIFIANTS ===

cd appNotes

echo 1. Reset de la base de donnees...
php artisan migrate:fresh --seed

echo.
echo 2. Test des identifiants:
echo Admin: admin@gestion-notes.com / password
echo Professeur: prof@test.com / password
echo Etudiant: etudiant@test.com / password

echo.
echo 3. Verification en base:
php artisan tinker --execute="echo 'Utilisateurs:'; App\Models\User::all(['name', 'email', 'role_id'])->each(function($u) { echo $u->name . ' - ' . $u->email . ' - Role: ' . $u->role_id . PHP_EOL; });"

pause