<?php

// Test de connexion simple
try {
    // Essayer avec mot de passe vide
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=gestion_notes', 'root', '');
    echo "Connexion OK avec mot de passe vide\n";
} catch (Exception $e) {
    try {
        // Essayer avec mot de passe 'root'
        $pdo = new PDO('mysql:host=127.0.0.1;dbname=gestion_notes', 'root', 'root');
        echo "Connexion OK avec mot de passe 'root'\n";
    } catch (Exception $e2) {
        echo "Erreur de connexion: " . $e2->getMessage() . "\n";
        echo "Verifiez que XAMPP MySQL est demarre\n";
        exit;
    }
}

// Créer les utilisateurs
$password = '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'; // hash de 'password'

$pdo->exec("DELETE FROM users");
$pdo->exec("DELETE FROM roles");

$pdo->exec("INSERT INTO roles (id, name, created_at) VALUES 
    (1, 'etudiant', NOW()),
    (2, 'professeur', NOW()), 
    (3, 'administration', NOW())");

$pdo->exec("INSERT INTO users (name, email, password, role_id, created_at, updated_at) VALUES 
    ('Admin', 'admin@gestion-notes.com', '$password', 3, NOW(), NOW()),
    ('Professeur Test', 'prof@test.com', '$password', 2, NOW(), NOW()),
    ('Etudiant Test', 'etudiant@test.com', '$password', 1, NOW(), NOW())");

echo "Utilisateurs créés!\n";
echo "Tous les mots de passe: password\n";