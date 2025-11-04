@echo off
echo === REPARATION PROJET LOCAL ===

echo 1. Verification XAMPP...
tasklist | findstr "httpd.exe" >nul || (
    echo ERREUR: Apache non demarre - Ouvrir XAMPP et demarrer Apache
    pause
    exit /b 1
)

tasklist | findstr "mysqld.exe" >nul || (
    echo ERREUR: MySQL non demarre - Ouvrir XAMPP et demarrer MySQL  
    pause
    exit /b 1
)

echo XAMPP services: OK

echo 2. Creation de la base de donnees...
mysql -u root -e "DROP DATABASE IF EXISTS gestion_notes; CREATE DATABASE gestion_notes;" 2>nul || (
    echo Tentative avec mot de passe...
    mysql -u root -proot -e "DROP DATABASE IF EXISTS gestion_notes; CREATE DATABASE gestion_notes;" 2>nul || (
        echo ERREUR: Impossible de se connecter a MySQL
        echo Verifiez le mot de passe root dans XAMPP
        pause
        exit /b 1
    )
)

echo Base de donnees creee: OK

echo 3. Configuration Laravel...
cd appNotes
copy .env.example .env >nul 2>&1
php artisan key:generate

echo 4. Installation des dependances...
composer install --no-dev

echo 5. Migration et seeders...
php artisan migrate:fresh --seed

echo 6. Test de connexion...
php artisan tinker --execute="echo 'Test DB: '; try { DB::connection()->getPdo(); echo 'OK'; } catch(Exception \$e) { echo 'KO: ' . \$e->getMessage(); }"

echo 7. Demarrage des serveurs...
start /b php artisan serve
cd ..\frontend
start /b npm run dev

echo === PROJET REPARE ===
echo Frontend: http://localhost:5173
echo Backend: http://localhost:8000
echo.
echo Identifiants:
echo admin@gestion-notes.com / password
echo prof@test.com / password
echo etudiant@test.com / password

pause