@echo off
echo === TEST BASE DE DONNEES ===

echo 1. Test connexion sans mot de passe...
mysql -u root -e "SELECT 'Connexion OK' as status;" 2>nul && (
    echo Connexion reussie sans mot de passe
    set DB_PASSWORD=
    goto :create_db
)

echo 2. Test connexion avec mot de passe 'root'...
mysql -u root -proot -e "SELECT 'Connexion OK' as status;" 2>nul && (
    echo Connexion reussie avec mot de passe 'root'
    set DB_PASSWORD=root
    goto :create_db
)

echo ERREUR: Impossible de se connecter a MySQL
echo Verifiez que XAMPP MySQL est demarre
pause
exit /b 1

:create_db
echo 3. Creation de la base...
if "%DB_PASSWORD%"=="" (
    mysql -u root -e "DROP DATABASE IF EXISTS gestion_notes; CREATE DATABASE gestion_notes;"
) else (
    mysql -u root -p%DB_PASSWORD% -e "DROP DATABASE IF EXISTS gestion_notes; CREATE DATABASE gestion_notes;"
)

echo 4. Mise a jour du fichier .env...
cd appNotes
copy .env.local .env
if not "%DB_PASSWORD%"=="" (
    powershell -Command "(Get-Content .env) -replace 'DB_PASSWORD=', 'DB_PASSWORD=%DB_PASSWORD%' | Set-Content .env"
)

echo Base de donnees configuree avec succes!
pause