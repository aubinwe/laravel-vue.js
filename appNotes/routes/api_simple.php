<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GradeController;
use App\Http\Controllers\ClaimController;
use Illuminate\Support\Facades\Route;

// Routes publiques
Route::post('/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    // Gestion des notes
    Route::apiResource('grades', GradeController::class);
    
    // Gestion des réclamations
    Route::apiResource('claims', ClaimController::class)->only(['index', 'store', 'update']);
});