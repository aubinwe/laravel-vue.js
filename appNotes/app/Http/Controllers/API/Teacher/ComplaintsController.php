<?php

namespace App\Http\Controllers\API\Teacher;

use App\Http\Controllers\Controller;
use App\Models\Complaint;
use Illuminate\Http\Request;

class ComplaintsController extends Controller
{
    protected function teacherSubjectIds(Request $request): array
    {
        return $request->user()->subjects()->pluck('subjects.id')->all();
    }

    public function index(Request $request)
    {
        $subjectIds = $this->teacherSubjectIds($request);
        $query = Complaint::with(['grade.subject:id,name,coefficient', 'grade:id,subject_id,score','user:id,name'])
            ->whereHas('grade', function ($q) use ($subjectIds) {
                $q->whereIn('subject_id', $subjectIds);
            })
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        return response()->json($query->paginate(20));
    }

    public function update(Request $request, Complaint $complaint)
    {
        $subjectIds = $this->teacherSubjectIds($request);
        abort_if(!in_array((int)$complaint->grade->subject_id, $subjectIds, true), 403);

        $data = $request->validate([
            'status' => ['sometimes','in:pending,resolved,rejected'],
        ]);

        $complaint->update($data);
        return response()->json($complaint->load(['grade.subject:id,name,coefficient','grade:id,subject_id,score','user:id,name']));
    }
}
