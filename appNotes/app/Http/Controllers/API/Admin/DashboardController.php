<?php

namespace App\Http\Controllers\API\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Grade;
use App\Models\Subject;
use App\Models\Complaint;

class DashboardController extends Controller
{
    public function summary()
    {
        $studentsCount = User::where('role', 'user')->count();
        $openComplaints = Complaint::where('status', 'pending')->count();

        // moyenne globale pondérée
        $grades = Grade::with('subject')->get();
        $sum = 0; $coef = 0;
        foreach ($grades as $g) {
            $c = $g->subject?->coefficient ?? 1;
            $sum += (float)$g->score * $c; $coef += $c;
        }
        $globalAverage = $coef > 0 ? round($sum / $coef, 2) : null;

        return response()->json([
            'students' => $studentsCount,
            'open_complaints' => $openComplaints,
            'global_average' => $globalAverage,
        ]);
    }
}
