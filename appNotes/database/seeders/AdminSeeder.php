<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Role;
use App\Models\Student;
use App\Models\Course;
use App\Models\Grade;
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
        Student::firstOrCreate(
            ['user_id' => $etudiant->id],
            [
                'matricule' => 'ETU20240001',
                'filiere' => 'Informatique',
            ]
        );
        
        // Créer des cours
        $courses = [
            ['name' => 'Mathématiques', 'code' => 'MATH101', 'coefficient' => 3, 'professor_id' => $prof->id],
            ['name' => 'Physique', 'code' => 'PHYS101', 'coefficient' => 2, 'professor_id' => $prof->id],
            ['name' => 'Informatique', 'code' => 'INFO101', 'coefficient' => 4, 'professor_id' => $prof->id],
        ];
        
        foreach ($courses as $courseData) {
            Course::firstOrCreate(['code' => $courseData['code']], $courseData);
        }
        
        echo "Utilisateurs créés avec succès !\n";
        echo "Admin: admin@gestion-notes.com / password\n";
        echo "Professeur: prof@test.com / password\n";
        echo "Étudiant: etudiant@test.com / password\n";
    }
}