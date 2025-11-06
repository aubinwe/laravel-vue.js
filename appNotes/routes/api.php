<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GradeController;
use App\Http\Controllers\ClaimController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\CourseController;
use App\Http\Controllers\BulletinController;

Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

Route::get('/metrics', [App\Http\Controllers\MetricsController::class, 'metrics'])->withoutMiddleware(['auth:sanctum']);

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/grades', [GradeController::class, 'index']);
    Route::post('/grades', [GradeController::class, 'store']);
    Route::put('/grades/{grade}', [GradeController::class, 'update']);
    Route::delete('/grades/{grade}', [GradeController::class, 'destroy']);
    Route::get('/claims', [ClaimController::class, 'index']);
    Route::post('/claims', [ClaimController::class, 'store']);
    Route::put('/claims/{claim}', [ClaimController::class, 'update']);
    Route::delete('/claims/{claim}', [ClaimController::class, 'destroy']);
    Route::get('/students', [StudentController::class, 'index']);
    Route::post('/students', [StudentController::class, 'store']);
    Route::get('/students/{student}', [StudentController::class, 'show']);
    Route::put('/students/{student}', [StudentController::class, 'update']);
    Route::delete('/students/{student}', [StudentController::class, 'destroy']);
    Route::get('/courses', [CourseController::class, 'index']);
    Route::post('/courses', [CourseController::class, 'store']);
    Route::put('/courses/{course}', [CourseController::class, 'update']);
    Route::delete('/courses/{course}', [CourseController::class, 'destroy']);
    Route::get('/bulletin/{student}', [BulletinController::class, 'generate']);
});