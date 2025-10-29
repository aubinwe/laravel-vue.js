<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Student;
use App\Models\Grade;
use Illuminate\Http\Request;

class DebugController extends Controller
{
    public function checkUser(Request $request)
    {
        $user = $request->user();
        
        $debug = [
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role_id' => $user->role_id,
                'role_name' => $user->role->name ?? 'N/A'
            ],
            'student' => null,
            'grades' => []
        ];
        
        if ($user->isEtudiant()) {
            $student = $user->student;
            if ($student) {
                $debug['student'] = [
                    'id' => $student->id,
                    'user_id' => $student->user_id,
                    'matricule' => $student->matricule,
                    'filiere' => $student->filiere
                ];
                
                $grades = Grade::with(['course'])
                    ->where('student_id', $student->id)
                    ->get();
                    
                $debug['grades'] = $grades->map(function($grade) {
                    return [
                        'id' => $grade->id,
                        'note' => $grade->note,
                        'semestre' => $grade->semestre,
                        'course' => $grade->course->name ?? 'N/A'
                    ];
                });
            } else {
                $debug['error'] = 'Profil étudiant manquant';
            }
        }
        
        return response()->json($debug);
    }
}