<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class StudentController extends Controller
{
    public function index(Request $request)
    {
        $q = User::where('role', 'user')->orderBy('id', 'desc');
        return response()->json($q->paginate(20));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'first_name' => ['required','string','max:100'],
            'last_name' => ['required','string','max:100'],
            'name' => ['nullable','string','max:255'],
            'email' => ['required','email','unique:users,email'],
            'matricule' => ['required','string','max:50','unique:users,matricule'],
            'filiere' => ['nullable','string','max:100'],
            'password' => ['required','string','min:8'],
        ]);
        $user = User::create([
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'name' => $data['name'] ?? ($data['first_name'].' '.$data['last_name']),
            'email' => $data['email'],
            'matricule' => $data['matricule'],
            'filiere' => $data['filiere'] ?? null,
            'password' => Hash::make($data['password']),
            'role' => 'user',
        ]);
        return response()->json($user, 201);
    }

    public function show(User $student)
    {
        abort_if($student->role !== 'user', 404);
        return response()->json($student);
    }

    public function update(Request $request, User $student)
    {
        abort_if($student->role !== 'user', 404);
        $data = $request->validate([
            'first_name' => ['sometimes','required','string','max:100'],
            'last_name' => ['sometimes','required','string','max:100'],
            'name' => ['sometimes','nullable','string','max:255'],
            'email' => ['sometimes','required','email','unique:users,email,'.$student->id],
            'matricule' => ['sometimes','required','string','max:50','unique:users,matricule,'.$student->id],
            'filiere' => ['sometimes','nullable','string','max:100'],
            'password' => ['nullable','string','min:8'],
        ]);
        if (!empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        } else {
            unset($data['password']);
        }
        $student->update($data);
        return response()->json($student);
    }

    public function destroy(User $student)
    {
        abort_if($student->role !== 'user', 404);
        $student->delete();
        return response()->json(['message' => 'deleted']);
    }
}
