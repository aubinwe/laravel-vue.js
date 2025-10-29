<?php

namespace App\Http\Controllers\API\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use App\Models\Subject;
use Illuminate\Http\Request;

class GradesController extends Controller
{
    protected function teacherSubjectIds(Request $request): array
    {
        return $request->user()->subjects()->pluck('subjects.id')->all();
    }

    public function index(Request $request)
    {
        $subjectIds = $this->teacherSubjectIds($request);
        $query = Grade::with(['user:id,name','subject:id,name,coefficient'])
            ->whereIn('subject_id', $subjectIds)
            ->orderByDesc('id');

        if ($request->filled('subject_id')) {
            $sid = (int)$request->input('subject_id');
            abort_if(!in_array($sid, $subjectIds, true), 403);
            $query->where('subject_id', $sid);
        }
        if ($request->filled('user_id')) {
            $query->where('user_id', (int)$request->input('user_id'));
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
        $subjectIds = $this->teacherSubjectIds($request);
        abort_if(!in_array((int)$data['subject_id'], $subjectIds, true), 403);

        $grade = Grade::create($data);
        return response()->json($grade->load(['user:id,name','subject:id,name,coefficient']), 201);
    }

    public function update(Request $request, Grade $grade)
    {
        $subjectIds = $this->teacherSubjectIds($request);
        abort_if(!in_array((int)$grade->subject_id, $subjectIds, true), 403);

        $data = $request->validate([
            'score' => ['sometimes','required','numeric','min:0','max:20'],
        ]);
        $grade->update($data);
        return response()->json($grade->load(['user:id,name','subject:id,name,coefficient']));
    }

    public function destroy(Request $request, Grade $grade)
    {
        $subjectIds = $this->teacherSubjectIds($request);
        abort_if(!in_array((int)$grade->subject_id, $subjectIds, true), 403);
        $grade->delete();
        return response()->json(['message' => 'deleted']);
    }
}
