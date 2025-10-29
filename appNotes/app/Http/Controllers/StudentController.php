<?php

namespace App\Http\Controllers;

use App\Models\Student;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class StudentController extends Controller
{
    public function index()
    {
        $students = Student::with('user')->get();
        return response()->json($students);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users',
            'filiere' => 'required|string|max:100',
            'password' => 'required|string|min:6'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role_id' => 1 // Étudiant
        ]);

        // Générer automatiquement le matricule
        $matricule = $this->generateMatricule();

        $student = Student::create([
            'user_id' => $user->id,
            'matricule' => $matricule,
            'filiere' => $request->filiere
        ]);

        return response()->json($student->load('user'), 201);
    }

    public function destroy($id)
    {
        $student = Student::findOrFail($id);
        $user = $student->user;
        
        $student->delete();
        $user->delete();
        
        return response()->json(['message' => 'Étudiant supprimé avec succès']);
    }

    private function generateMatricule()
    {
        $year = date('Y');
        
        // Compter le nombre d'étudiants existants pour cette année
        $count = Student::where('matricule', 'LIKE', 'ETU' . $year . '%')->count();
        $number = $count + 1;
        
        // Vérifier que le matricule n'existe pas déjà
        do {
            $matricule = 'ETU' . $year . str_pad($number, 4, '0', STR_PAD_LEFT);
            $exists = Student::where('matricule', $matricule)->exists();
            if ($exists) {
                $number++;
            }
        } while ($exists);
        
        return $matricule;
    }
}