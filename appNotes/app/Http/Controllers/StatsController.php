<?php

namespace App\Http\Controllers;

use App\Models\Student;
use App\Models\Grade;
use App\Models\Claim;
use App\Models\Course;
use Illuminate\Http\Request;

class StatsController extends Controller
{
    public function index()
    {
        $stats = [
            'total_students' => Student::count(),
            'total_grades' => Grade::count(),
            'total_claims' => Claim::count(),
            'total_courses' => Course::count(),
        ];

        return response()->json($stats);
    }
}