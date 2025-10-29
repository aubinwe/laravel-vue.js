<?php

namespace App\Http\Controllers\API\Student;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $u = $request->user();
        return response()->json([
            'id' => $u->id,
            'first_name' => $u->first_name,
            'last_name' => $u->last_name,
            'name' => $u->name,
            'email' => $u->email,
            'matricule' => $u->matricule,
            'filiere' => $u->filiere,
            'role' => $u->role,
        ]);
    }
}
