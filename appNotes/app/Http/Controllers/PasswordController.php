<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class PasswordController extends Controller
{
    public function change(Request $request)
    {
        $request->validate([
            'current_password' => 'required',
            'new_password' => 'required|min:6|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Le mot de passe actuel est incorrect.'],
            ]);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json(['message' => 'Mot de passe changé avec succès']);
    }
}