<?php

namespace App\Http\Controllers;

use App\Models\Claim;
use Illuminate\Http\Request;

class ClaimController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->isAdmin() || $user->isProfesseur()) {
            $claims = Claim::with(['student.user', 'course'])->get();
        } else {
            // Étudiant voit ses réclamations
            $student = $user->student;
            if (!$student) {
                return response()->json([]);
            }
            $claims = Claim::with(['course'])
                ->where('student_id', $student->id)
                ->get();
        }

        return response()->json($claims);
    }

    public function store(Request $request)
    {
        $request->validate([
            'course_id' => 'required|exists:courses,id',
            'motif' => 'required|string',
            'description' => 'required|string'
        ]);

        $user = $request->user();
        $student = $user->student;
        
        if (!$student) {
            return response()->json(['error' => 'Profil étudiant non trouvé'], 400);
        }

        $claim = Claim::create([
            'student_id' => $student->id,
            'course_id' => $request->course_id,
            'motif' => $request->motif,
            'description' => $request->description,
            'statut' => 'en_attente'
        ]);

        return response()->json($claim->load(['student.user', 'course']), 201);
    }

    public function update(Request $request, Claim $claim)
    {
        $request->validate([
            'statut' => 'required|in:en_attente,approuve,rejete'
        ]);

        $claim->update(['statut' => $request->statut]);
        
        return response()->json($claim->load(['student.user', 'course']));
    }
}