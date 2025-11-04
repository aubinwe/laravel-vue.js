@echo off
echo === CORRECTION AUTHENTIFICATION ===

cd appNotes

echo 1. Nettoyage complet...
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo 2. Verification des routes...
php artisan route:list | findstr "login" && echo [OK] Route login existe || echo [ERREUR] Route login manquante

echo 3. Recreation base et utilisateurs...
php artisan migrate:fresh --seed

echo 4. Verification utilisateurs crees...
php artisan tinker --execute="
\$users = App\Models\User::with('role')->get();
foreach(\$users as \$user) {
    echo \$user->email . ' - ' . \$user->role->name . ' - Hash: ' . substr(\$user->password, 0, 20) . '...' . PHP_EOL;
}
"

echo 5. Test hash mot de passe...
php artisan tinker --execute="
\$user = App\Models\User::where('email', 'admin@gestion-notes.com')->first();
if(\$user) {
    echo 'Test hash pour admin: ' . (Hash::check('password', \$user->password) ? 'OK' : 'KO') . PHP_EOL;
}
"

echo 6. Test API login...
start /b php artisan serve
timeout /t 3

curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d "{\"email\":\"admin@gestion-notes.com\",\"password\":\"password\"}" -w "\nStatus: %{http_code}\n"

echo.
echo === IDENTIFIANTS CORRECTS ===
echo admin@gestion-notes.com / password
echo prof@test.com / password
echo etudiant@test.com / password

pause