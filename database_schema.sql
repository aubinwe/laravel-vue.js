-- 🗄️ Base de données - Gestion de Notes
-- Création des tables principales

CREATE DATABASE IF NOT EXISTS gestion_notes;
USE gestion_notes;

-- Table des rôles
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des utilisateurs
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Table des étudiants
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    matricule VARCHAR(20) NOT NULL UNIQUE,
    filiere VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table des cours
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL UNIQUE,
    coefficient INT NOT NULL DEFAULT 1,
    professor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (professor_id) REFERENCES users(id)
);

-- Table des notes
CREATE TABLE grades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    note DECIMAL(4,2) NOT NULL,
    semestre VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Table des réclamations
CREATE TABLE claims (
    id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    commentaire TEXT NOT NULL,
    statut ENUM('en_attente', 'approuve', 'rejete') DEFAULT 'en_attente',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES grades(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Table des délibérations
CREATE TABLE deliberations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    grade_id INT NOT NULL,
    note_finale DECIMAL(4,2) NOT NULL,
    statut_validation ENUM('en_cours', 'valide', 'rejete') DEFAULT 'en_cours',
    validated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (grade_id) REFERENCES grades(id) ON DELETE CASCADE,
    FOREIGN KEY (validated_by) REFERENCES users(id)
);

-- Insertion des rôles par défaut
INSERT INTO roles (name) VALUES 
('etudiant'),
('professeur'),
('administration');

-- Utilisateur admin par défaut
INSERT INTO users (name, email, password, role_id) VALUES 
('Admin', 'admin@gestion-notes.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 3);

-- Index pour optimiser les performances
CREATE INDEX idx_grades_student_course ON grades(student_id, course_id);
CREATE INDEX idx_claims_status ON claims(statut);
CREATE INDEX idx_deliberations_status ON deliberations(statut_validation);