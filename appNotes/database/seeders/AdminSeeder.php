<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AdminSeeder extends Seeder
{
    public function run()
    {
        try {
            // Vider les tables d'abord
            DB::statement('SET FOREIGN_KEY_CHECKS=0;');
            DB::table('grades')->truncate();
            DB::table('students')->truncate();
            DB::table('courses')->truncate();
            DB::table('users')->truncate();
            DB::table('roles')->truncate();
            DB::statement('SET FOREIGN_KEY_CHECKS=1;');
            
            // Créer les rôles
            DB::table('roles')->insert([
                ['id' => 1, 'name' => 'etudiant', 'created_at' => now()],
                ['id' => 2, 'name' => 'professeur', 'created_at' => now()],
                ['id' => 3, 'name' => 'administration', 'created_at' => now()],
            ]);

            // Créer l'utilisateur admin
            DB::table('users')->insert([
                'id' => 1,
                'name' => 'Admin',
                'email' => 'admin@gestion-notes.com',
                'password' => Hash::make('password'),
                'role_id' => 3,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Créer un professeur de test
            DB::table('users')->insert([
                'id' => 2,
                'name' => 'Professeur Test',
                'email' => 'prof@test.com',
                'password' => Hash::make('password'),
                'role_id' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Créer un étudiant de test
            DB::table('users')->insert([
                'id' => 3,
                'name' => 'Étudiant Test',
                'email' => 'etudiant@test.com',
                'password' => Hash::make('password'),
                'role_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Créer le profil étudiant
            DB::table('students')->insert([
                'id' => 1,
                'user_id' => 3,
                'matricule' => 'ETU20240001',
                'filiere' => 'Informatique',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Créer des cours de test
            DB::table('courses')->insert([
                [
                    'id' => 1,
                    'name' => 'Mathématiques',
                    'code' => 'MATH101',
                    'coefficient' => 3,
                    'professor_id' => 2,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'id' => 2,
                    'name' => 'Physique',
                    'code' => 'PHYS101',
                    'coefficient' => 2,
                    'professor_id' => 2,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'id' => 3,
                    'name' => 'Informatique',
                    'code' => 'INFO101',
                    'coefficient' => 4,
                    'professor_id' => 2,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            ]);
            
            // Créer des notes de test
            DB::table('grades')->insert([
                [
                    'student_id' => 1,
                    'course_id' => 1,
                    'note' => 15.50,
                    'semestre' => 'S1 2024',
                    'statut' => 'en_cours',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'student_id' => 1,
                    'course_id' => 2,
                    'note' => 12.00,
                    'semestre' => 'S1 2024',
                    'statut' => 'en_cours',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'student_id' => 1,
                    'course_id' => 3,
                    'note' => 17.25,
                    'semestre' => 'S1 2024',
                    'statut' => 'en_cours',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);
            
            echo "Seeder exécuté avec succès !\n";
            
        } catch (\Exception $e) {
            echo "Erreur dans le seeder: " . $e->getMessage() . "\n";
            throw $e;
        }
    }
}