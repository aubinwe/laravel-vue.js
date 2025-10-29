<?php

namespace App\Http\Controllers;

use App\Models\Course;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    public function index()
    {
        $courses = Course::with('professor')->get();
        return response()->json($courses);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:100',
            'code' => 'required|string|max:20|unique:courses',
            'coefficient' => 'required|integer|min:1',
            'professor_id' => 'nullable|exists:users,id'
        ]);

        $course = Course::create($request->all());
        return response()->json($course->load('professor'), 201);
    }
}