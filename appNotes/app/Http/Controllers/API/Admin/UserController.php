<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query()->orderBy('id', 'desc');
        if ($request->filled('role')) {
            $query->where('role', $request->string('role'));
        }
        if ($request->filled('q')) {
            $q = '%'.$request->string('q').'%';
            $query->where(function($w) use ($q){
                $w->where('name','like',$q)->orWhere('email','like',$q);
            });
        }
        return response()->json($query->paginate(20));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required','string','max:150'],
            'email' => ['required','email','max:255','unique:users,email'],
            'password' => ['nullable','string','min:6'],
            'role' => ['required', Rule::in(['admin','teacher','user'])],
        ]);
        $user = new User();
        $user->name = $data['name'];
        $user->email = $data['email'];
        $user->role = $data['role'];
        $user->password = Hash::make($data['password'] ?? 'password');
        $user->save();
        return response()->json($user, 201);
    }

    public function show(User $user)
    {
        return response()->json($user);
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'name' => ['sometimes','string','max:150'],
            'email' => ['sometimes','email','max:255', Rule::unique('users','email')->ignore($user->id)],
            'password' => ['nullable','string','min:6'],
            'role' => ['sometimes', Rule::in(['admin','teacher','user'])],
        ]);
        if (array_key_exists('name',$data)) $user->name = $data['name'];
        if (array_key_exists('email',$data)) $user->email = $data['email'];
        if (array_key_exists('role',$data)) $user->role = $data['role'];
        if (!empty($data['password'])) $user->password = Hash::make($data['password']);
        $user->save();
        return response()->json($user);
    }

    public function destroy(User $user)
    {
        $user->delete();
        return response()->json(['message' => 'deleted']);
    }
}
