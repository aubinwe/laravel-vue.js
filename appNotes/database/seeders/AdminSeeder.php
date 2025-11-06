<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Role;
use App\Models\Student;
use App\Models\Course;
use App\Models\Grade;
use App\Models\Claim;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        // Créer les rôles
        $roles = [
            ['name' => 'etudiant'],
            ['name' => 'professeur'],
            ['name' => 'administration'],
        ];
        
        foreach ($roles as $role) {
            Role::firstOrCreate($role);
        }
        
        // Récupérer les rôles
        $adminRole = Role::where('name', 'administration')->first();
        $profRole = Role::where('name', 'professeur')->first();
        $studentRole = Role::where('name', 'etudiant')->first();
        
        // Créer l'admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@gestion-notes.com'],
            [
                'name' => 'Admin',
                'password' => Hash::make('password'),
                'role_id' => $adminRole->id,
            ]
        );
        
        // Créer le professeur
        $prof = User::firstOrCreate(
            ['email' => 'prof@test.com'],
            [
                'name' => 'Professeur Test',
                'password' => Hash::make('password'),
                'role_id' => $profRole->id,
            ]
        );
        
        // Créer l'étudiant
        $etudiant = User::firstOrCreate(
            ['email' => 'etudiant@test.com'],
            [
                'name' => 'Étudiant Test',
                'password' => Hash::make('password'),
                'role_id' => $studentRole->id,
            ]
        );
        
        // Créer le profil étudiant
        $student = Student::firstOrCreate(
            ['user_id' => $etudiant->id],
            [
                'matricule' => 'ETU20240001',
                'filiere' => 'Informatique',
            ]
        );
        
        // Créer des cours
        $mathCourse = Course::firstOrCreate(
            ['code' => 'MATH101'],
            ['name' => 'Mathématiques', 'coefficient' => 3, 'professor_id' => $prof->id]
        );
        
        $physCourse = Course::firstOrCreate(
            ['code' => 'PHYS101'],
            ['name' => 'Physique', 'coefficient' => 2, 'professor_id' => $prof->id]
        );
        
        $infoCourse = Course::firstOrCreate(
            ['code' => 'INFO101'],
            ['name' => 'Informatique', 'coefficient' => 4, 'professor_id' => $prof->id]
        );
        
        // Créer des notes
        Grade::firstOrCreate(
            ['student_id' => $student->id, 'course_id' => $mathCourse->id],
            ['note' => 15.5, 'semestre' => 'S1 2024', 'statut' => 'en_cours']
        );
        
        Grade::firstOrCreate(
            ['student_id' => $student->id, 'course_id' => $physCourse->id],
            ['note' => 12.0, 'semestre' => 'S1 2024', 'statut' => 'en_cours']
        );
        
        Grade::firstOrCreate(
            ['student_id' => $student->id, 'course_id' => $infoCourse->id],
            ['note' => 17.25, 'semestre' => 'S1 2024', 'statut' => 'en_cours']
        );
        
        // Créer des réclamations
        Claim::firstOrCreate(
            ['student_id' => $student->id, 'course_id' => $mathCourse->id],
            [
                'motif' => 'Erreur de calcul',
                'description' => 'Je pense qu\'il y a une erreur dans le calcul de ma note',
                'statut' => 'en_attente'
            ]
        );
        
        echo "Données créées avec succès !\n";
        echo "Admin: admin@gestion-notes.com / password\n";
        echo "Professeur: prof@test.com / password\n";
        echo "Étudiant: etudiant@test.com / password\n";
    }
}