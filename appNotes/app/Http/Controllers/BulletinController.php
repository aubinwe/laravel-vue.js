<?php

namespace App\Http\Controllers;

use App\Models\Grade;
use Illuminate\Http\Request;

class BulletinController extends Controller
{
    public function download(Request $request)
    {
        $user = $request->user();
        
        if (!$user->isEtudiant()) {
            return response()->json(['error' => 'Non autorisé'], 403);
        }
        
        $student = $user->student;
        if (!$student) {
            return response()->json(['error' => 'Profil étudiant non trouvé'], 404);
        }
        
        $grades = Grade::with(['course'])
            ->where('student_id', $student->id)
            ->get();
            
        if ($grades->isEmpty()) {
            return response()->json(['error' => 'Aucune note disponible'], 404);
        }

        $data = [
            'student' => $student,
            'user' => $user,
            'grades' => $grades,
            'moyenne' => $grades->avg('note')
        ];

        // Générer le HTML du bulletin
        $html = view('bulletin', $data)->render();
        
        // Retourner le HTML pour test (plus tard on utilisera un générateur PDF)
        return response($html, 200, [
            'Content-Type' => 'text/html',
            'Content-Disposition' => 'attachment; filename="bulletin_' . $student->matricule . '.html"'
        ]);
    }
}