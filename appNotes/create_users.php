<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\Hash;

// Configuration de base
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

try {
    // Connexion directe à la base
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=gestion_notes', 'root', '');
    
    // Supprimer les utilisateurs existants
    $pdo->exec("DELETE FROM grades");
    $pdo->exec("DELETE FROM students");  
    $pdo->exec("DELETE FROM users");
    $pdo->exec("DELETE FROM roles");
    
    // Créer les rôles
    $pdo->exec("INSERT INTO roles (id, name, created_at) VALUES 
        (1, 'etudiant', NOW()),
        (2, 'professeur', NOW()), 
        (3, 'administration', NOW())");
    
    // Hash du mot de passe
    $password = password_hash('password', PASSWORD_DEFAULT);
    
    // Créer les utilisateurs
    $pdo->exec("INSERT INTO users (name, email, password, role_id, created_at, updated_at) VALUES 
        ('Admin', 'admin@gestion-notes.com', '$password', 3, NOW(), NOW()),
        ('Professeur Test', 'prof@test.com', '$password', 2, NOW(), NOW()),
        ('Etudiant Test', 'etudiant@test.com', '$password', 1, NOW(), NOW())");
    
    echo "Utilisateurs créés avec succès!\n";
    echo "admin@gestion-notes.com / password\n";
    echo "prof@test.com / password\n"; 
    echo "etudiant@test.com / password\n";
    
} catch (Exception $e) {
    echo "Erreur: " . $e->getMessage() . "\n";
}