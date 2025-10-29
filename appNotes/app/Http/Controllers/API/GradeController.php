<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use App\Models\User;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Grade::with(['user:id,name', 'subject:id,name,coefficient']);

        if ($user->role !== 'admin') {
            $query->where('user_id', $user->id);
        } else if ($request->filled('user_id')) {
            $query->where('user_id', (int)$request->input('user_id'));
        }

        $grades = $query->latest()->paginate(20);
        return response()->json($grades);
    }

    public function average(Request $request)
    {
        $user = $request->user();
        $query = Grade::query()->with('subject:id,coefficient');
        if ($user->role !== 'admin') {
            $query->where('user_id', $user->id);
        } else if ($request->filled('user_id')) {
            $query->where('user_id', (int)$request->input('user_id'));
        }
        $sum = 0; $coef = 0;
        foreach ($query->get() as $g) {
            $c = $g->subject?->coefficient ?? 1;
            $sum += (float)$g->score * $c; $coef += $c;
        }
        $avg = $coef > 0 ? round($sum / $coef, 2) : null;
        return response()->json(['average' => $avg]);
    }
}
