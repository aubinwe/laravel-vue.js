@echo off
echo === SOLUTION RAPIDE ===

cd appNotes

echo 1. Nettoyage cache Laravel...
php artisan config:clear
php artisan cache:clear
php artisan route:clear

echo 2. Test connexion...
php -r "
\$config = [
    'host' => 'localhost',
    'dbname' => 'gestion_notes', 
    'user' => 'root',
    'pass' => ''
];

try {
    \$pdo = new PDO('mysql:host='.\$config['host'].';dbname='.\$config['dbname'], \$config['user'], \$config['pass']);
    echo 'Connexion DB: OK\n';
    
    // Créer utilisateurs directement
    \$pdo->exec('DELETE FROM users');
    \$pdo->exec('DELETE FROM roles');
    
    \$pdo->exec('INSERT INTO roles (id, name, created_at) VALUES (1, \"etudiant\", NOW()), (2, \"professeur\", NOW()), (3, \"administration\", NOW())');
    
    \$hash = password_hash('password', PASSWORD_DEFAULT);
    \$pdo->exec('INSERT INTO users (name, email, password, role_id, created_at, updated_at) VALUES 
        (\"Admin\", \"admin@gestion-notes.com\", \"'.\$hash.'\", 3, NOW(), NOW()),
        (\"Professeur\", \"prof@test.com\", \"'.\$hash.'\", 2, NOW(), NOW()),
        (\"Etudiant\", \"etudiant@test.com\", \"'.\$hash.'\", 1, NOW(), NOW())');
    
    echo 'Utilisateurs créés: OK\n';
    
} catch(Exception \$e) {
    echo 'ERREUR: ' . \$e->getMessage() . '\n';
    echo 'Vérifiez que XAMPP MySQL est démarré\n';
}
"

echo 3. Démarrage serveur...
start /b php artisan serve

echo === IDENTIFIANTS ===
echo admin@gestion-notes.com / password
echo prof@test.com / password  
echo etudiant@test.com / password

pause