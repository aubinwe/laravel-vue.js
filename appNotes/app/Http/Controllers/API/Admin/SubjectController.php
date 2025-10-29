<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use App\Models\User;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function index()
    {
        return response()->json(Subject::orderBy('name')->paginate(50));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required','string','max:150'],
            'coefficient' => ['required','integer','min:1','max:20'],
        ]);
        $subject = Subject::create($data);
        return response()->json($subject, 201);
    }

    public function show(Subject $subject)
    {
        return response()->json($subject);
    }

    public function update(Request $request, Subject $subject)
    {
        $data = $request->validate([
            'name' => ['sometimes','required','string','max:150'],
            'coefficient' => ['sometimes','required','integer','min:1','max:20'],
        ]);
        $subject->update($data);
        return response()->json($subject);
    }

    public function destroy(Subject $subject)
    {
        $subject->delete();
        return response()->json(['message' => 'deleted']);
    }

    // List teachers assigned to this subject
    public function teachers(Subject $subject)
    {
        $teachers = $subject->teachers()->select('users.id','users.name','users.email')->orderBy('name')->get();
        return response()->json($teachers);
    }

    // Assign teachers to this subject (sync pivot)
    public function assignTeachers(Request $request, Subject $subject)
    {
        $data = $request->validate([
            'teacher_ids' => ['array'],
            'teacher_ids.*' => ['integer','exists:users,id'],
        ]);
        // Ensure only users with role=teacher are synced
        $ids = isset($data['teacher_ids']) ? array_values(array_unique(array_map('intval', $data['teacher_ids']))) : [];
        $validIds = User::whereIn('id', $ids)->where('role','teacher')->pluck('id')->all();
        $subject->teachers()->sync($validIds);
        return response()->json(['assigned' => $validIds]);
    }
}
