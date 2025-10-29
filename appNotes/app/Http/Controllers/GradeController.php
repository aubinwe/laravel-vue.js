<?php

namespace App\Http\Controllers;

use App\Models\Grade;
use App\Models\Student;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->isEtudiant()) {
            // Étudiant voit SEULEMENT ses notes
            $student = $user->student;
            if (!$student) {
                return response()->json([]);
            }
            
            $grades = Grade::with(['course', 'deliberation'])
                ->where('student_id', $student->id)
                ->get();
                
            // Debug supprimé
            
        } elseif ($user->isProfesseur()) {
            // Professeur voit toutes les notes pour pouvoir en ajouter
            $grades = Grade::with(['student.user', 'course'])->get();
        } else {
            // Admin voit tout
            $grades = Grade::with(['student.user', 'course', 'deliberation'])->get();
        }

        return response()->json($grades);
    }

    public function store(Request $request)
    {
        $request->validate([
            'student_id' => 'required|exists:students,id',
            'course_id' => 'required|exists:courses,id',
            'note' => 'required|numeric|min:0|max:20',
            'semestre' => 'required|string'
        ]);

        $grade = Grade::create($request->all());
        
        return response()->json($grade->load(['student.user', 'course']), 201);
    }

    public function update(Request $request, Grade $grade)
    {
        $request->validate([
            'note' => 'required|numeric|min:0|max:20',
        ]);

        $grade->update($request->only('note'));
        
        return response()->json($grade->load(['student.user', 'course']));
    }

    public function destroy(Grade $grade)
    {
        $grade->delete();
        
        return response()->json(['message' => 'Note supprimée']);
    }
}