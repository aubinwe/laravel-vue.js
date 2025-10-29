<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\NoteController;
use App\Http\Controllers\API\GradeController;
use App\Http\Controllers\API\ComplaintController;
use App\Http\Controllers\API\ExportController;
use App\Http\Controllers\API\BulletinController;
use App\Http\Controllers\API\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\API\Admin\StudentController as AdminStudentController;
use App\Http\Controllers\API\Admin\SubjectController as AdminSubjectController;
use App\Http\Controllers\API\Admin\GradeController as AdminGradeController;
use App\Http\Controllers\API\Student\ProfileController as StudentProfileController;
use App\Http\Controllers\API\Teacher\GradesController as TeacherGradesController;
use App\Http\Controllers\API\Teacher\ComplaintsController as TeacherComplaintsController;

Route::prefix('v1')->group(function () {
    // Auth
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);

        // Notes CRUD
        Route::get('/notes', [NoteController::class, 'index']);
        Route::post('/notes', [NoteController::class, 'store']);
        Route::get('/notes/{note}', [NoteController::class, 'show']);
        Route::put('/notes/{note}', [NoteController::class, 'update']);
        Route::delete('/notes/{note}', [NoteController::class, 'destroy']);

        // Grades (notes scolaires)
        Route::get('/grades', [GradeController::class, 'index']);
        Route::get('/grades/average', [GradeController::class, 'average']);

        // Complaints (réclamations)
        Route::get('/complaints', [ComplaintController::class, 'index']);
        Route::post('/complaints', [ComplaintController::class, 'store']);
        Route::put('/complaints/{complaint}', [ComplaintController::class, 'update']); // admin can update status

        // Admin export
        Route::get('/admin/export/students', [ExportController::class, 'studentsCsv']);

        // Admin area
        Route::prefix('admin')->middleware('is_admin')->group(function () {
            Route::get('/dashboard', [AdminDashboardController::class, 'summary']);

            Route::apiResource('students', AdminStudentController::class);
            Route::apiResource('subjects', AdminSubjectController::class);
            Route::apiResource('grades', AdminGradeController::class)->only(['index','store','update','destroy']);
            Route::post('/grades/bulk', [AdminGradeController::class, 'bulkUpsert']);

            // Users management (create users with roles, list/filter)
            Route::apiResource('users', \App\Http\Controllers\API\Admin\UserController::class);

            // Subject teachers assignment
            Route::get('/subjects/{subject}/teachers', [AdminSubjectController::class, 'teachers']);
            Route::post('/subjects/{subject}/teachers', [AdminSubjectController::class, 'assignTeachers']);

            Route::get('/students/{student}/bulletin', [BulletinController::class, 'adminStudentBulletin']);
        });

        // Student area
        Route::prefix('student')->group(function () {
            Route::get('/profile', [StudentProfileController::class, 'show']);
            Route::get('/bulletin', [BulletinController::class, 'myBulletin']);
        });

        // Teacher area
        Route::prefix('teacher')->middleware('is_teacher')->group(function () {
            Route::get('/grades', [TeacherGradesController::class, 'index']);
            Route::post('/grades', [TeacherGradesController::class, 'store']);
            Route::put('/grades/{grade}', [TeacherGradesController::class, 'update']);
            Route::delete('/grades/{grade}', [TeacherGradesController::class, 'destroy']);

            Route::get('/complaints', [TeacherComplaintsController::class, 'index']);
            Route::put('/complaints/{complaint}', [TeacherComplaintsController::class, 'update']);
        });
    });
});
