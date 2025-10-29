<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    public function index(Request $request)
    {
        $query = Grade::with(['user:id,name','subject:id,name,coefficient'])
            ->orderByDesc('id');
        if ($request->filled('user_id')) {
            $query->where('user_id', (int)$request->input('user_id'));
        }
        if ($request->filled('subject_id')) {
            $query->where('subject_id', (int)$request->input('subject_id'));
        }
        return response()->json($query->paginate(20));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => ['required','integer','exists:users,id'],
            'subject_id' => ['required','integer','exists:subjects,id'],
            'score' => ['required','numeric','min:0','max:20'],
        ]);
        $grade = Grade::create($data);
        return response()->json($grade->load(['user:id,name','subject:id,name,coefficient']), 201);
    }

    public function update(Request $request, Grade $grade)
    {
        $data = $request->validate([
            'user_id' => ['sometimes','required','integer','exists:users,id'],
            'subject_id' => ['sometimes','required','integer','exists:subjects,id'],
            'score' => ['sometimes','required','numeric','min:0','max:20'],
        ]);
        $grade->update($data);
        return response()->json($grade->load(['user:id,name','subject:id,name,coefficient']));
    }

    public function destroy(Grade $grade)
    {
        $grade->delete();
        return response()->json(['message' => 'deleted']);
    }

    public function bulkUpsert(Request $request)
    {
        $data = $request->validate([
            'user_id' => ['required','integer','exists:users,id'],
            'items' => ['required','array','min:1'],
            'items.*.subject_id' => ['required','integer','exists:subjects,id'],
            'items.*.score' => ['nullable','numeric','min:0','max:20'],
        ]);

        $userId = (int)$data['user_id'];
        $changes = [];
        foreach ($data['items'] as $it) {
            if ($it['score'] === null || $it['score'] === '') { continue; }
            $grade = Grade::updateOrCreate(
                ['user_id' => $userId, 'subject_id' => (int)$it['subject_id']],
                ['score' => (float)$it['score']]
            );
            $changes[] = $grade->id;
        }
        return response()->json(['updated' => count($changes)]);
    }
}
