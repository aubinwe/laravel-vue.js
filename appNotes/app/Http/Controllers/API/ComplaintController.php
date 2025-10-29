<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use App\Models\Grade;
use Illuminate\Http\Request;

class ComplaintController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Complaint::with(['grade.subject:id,name,coefficient', 'grade:id,subject_id,score','user:id,name']);
        if ($user->role !== 'admin') {
            $query->where('user_id', $user->id);
        }
        $list = $query->latest()->paginate(20);
        return response()->json($list);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'grade_id' => ['required','integer','exists:grades,id'],
            'message' => ['required','string','max:2000'],
        ]);

        $grade = Grade::findOrFail($validated['grade_id']);
        $user = $request->user();
        if ($user->role !== 'admin' && $grade->user_id !== $user->id) {
            abort(403);
        }

        $complaint = Complaint::create([
            'user_id' => $user->id,
            'grade_id' => $grade->id,
            'message' => $validated['message'],
            'status' => 'pending',
        ]);

        return response()->json($complaint->load(['grade.subject:id,name,coefficient','grade:id,subject_id,score']), 201);
    }

    public function update(Request $request, Complaint $complaint)
    {
        $user = $request->user();
        if ($user->role !== 'admin') {
            abort(403);
        }
        $data = $request->validate([
            'status' => ['sometimes','in:pending,resolved,rejected'],
            'admin_notes' => ['nullable','string'],
        ]);
        $complaint->update($data);
        return response()->json($complaint->load(['grade.subject:id,name,coefficient','grade:id,subject_id,score','user:id,name']));
    }
}
