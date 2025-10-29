<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Note;
use App\Models\Subject;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin',
                'password' => Hash::make('password'),
                'role' => 'admin',
            ]
        );

        $user = User::updateOrCreate(
            ['email' => 'user@example.com'],
            [
                'name' => 'User',
                'password' => Hash::make('password'),
                'role' => 'user',
            ]
        );

        Note::updateOrCreate(['title' => 'Bienvenue', 'user_id' => $user->id], [
            'content' => 'Ceci est une note d\'exemple pour l\'utilisateur.',
        ]);

        Note::updateOrCreate(['title' => 'Admin note', 'user_id' => $admin->id], [
            'content' => 'Note visible pour l\'admin.',
        ]);

        // Subjects
        $math = Subject::updateOrCreate(['name' => 'Math'], ['coefficient' => 3]);
        $phys = Subject::updateOrCreate(['name' => 'Physique'], ['coefficient' => 2]);
        $cs = Subject::updateOrCreate(['name' => 'Informatique'], ['coefficient' => 4]);

        // Grades d'exemple (par matière)
        \App\Models\Grade::updateOrCreate(['user_id' => $user->id, 'subject_id' => $math->id], ['score' => 14.50]);
        \App\Models\Grade::updateOrCreate(['user_id' => $user->id, 'subject_id' => $phys->id], ['score' => 12.00]);
        \App\Models\Grade::updateOrCreate(['user_id' => $user->id, 'subject_id' => $cs->id], ['score' => 16.75]);
    }
}
