<?php
// Script pour vérifier les utilisateurs dans la base
$host = '127.0.0.1';
$dbname = 'gestion_notes';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "=== UTILISATEURS DANS LA BASE ===\n";
    $stmt = $pdo->query("SELECT u.id, u.name, u.email, r.name as role FROM users u JOIN roles r ON u.role_id = r.id");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "ID: {$row['id']}, Nom: {$row['name']}, Email: {$row['email']}, Rôle: {$row['role']}\n";
    }
    
    echo "\n=== RÔLES DANS LA BASE ===\n";
    $stmt = $pdo->query("SELECT * FROM roles");
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "ID: {$row['id']}, Nom: {$row['name']}\n";
    }
    
} catch(PDOException $e) {
    echo "Erreur : " . $e->getMessage();
}
?>