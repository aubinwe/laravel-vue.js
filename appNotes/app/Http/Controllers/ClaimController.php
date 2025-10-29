<?php

namespace App\Http\Controllers;

use App\Models\Claim;
use Illuminate\Http\Request;

class ClaimController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        if ($user->isAdmin()) {
            $claims = Claim::with(['grade.student.user', 'grade.course', 'creator'])->get();
        } else {
            $claims = Claim::with(['grade.student.user', 'grade.course'])
                ->where('created_by', $user->id)
                ->get();
        }

        return response()->json($claims);
    }

    public function store(Request $request)
    {
        $request->validate([
            'grade_id' => 'required|exists:grades,id',
            'commentaire' => 'required|string'
        ]);

        $claim = Claim::create([
            'grade_id' => $request->grade_id,
            'commentaire' => $request->commentaire,
            'created_by' => $request->user()->id
        ]);

        return response()->json($claim->load(['grade.student.user', 'grade.course']), 201);
    }

    public function update(Request $request, Claim $claim)
    {
        $request->validate([
            'statut' => 'required|in:en_attente,approuve,rejete'
        ]);

        $claim->update(['statut' => $request->statut]);
        
        return response()->json($claim->load(['grade.student.user', 'grade.course']));
    }
}