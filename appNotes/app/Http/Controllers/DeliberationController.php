<?php

namespace App\Http\Controllers;

use App\Models\Grade;
use Illuminate\Http\Request;

class DeliberationController extends Controller
{
    public function submitGrades(Request $request)
    {
        // Professeur soumet ses notes pour délibération
        $user = $request->user();
        
        Grade::whereHas('course', function($q) use ($user) {
            $q->where('professor_id', $user->id);
        })->update(['statut' => 'soumis']);
        
        return response()->json(['message' => 'Notes soumises pour délibération']);
    }
    
    public function deliberateGrades(Request $request)
    {
        // Admin délibère les notes
        Grade::where('statut', 'soumis')->update(['statut' => 'delibere']);
        
        return response()->json(['message' => 'Délibération effectuée']);
    }
}