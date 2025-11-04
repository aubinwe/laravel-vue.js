<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GradeController;
use App\Http\Controllers\ClaimController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\CourseController;
use App\Http\Controllers\BulletinController;

// 🏥 Route de santé
Route::get('/health', function () {
    return response()->json([
        'status' => 'OK',
        'timestamp' => now(),
        'database' => 'connected'
    ]);
});

// 🔐 Routes d'authentification
Route::post('/login', [AuthController::class, 'login']);

// 🛡️ Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    // 📊 Gestion des notes
    Route::apiResource('grades', GradeController::class);
    
    // 📝 Gestion des réclamations
    Route::apiResource('claims', ClaimController::class)->only(['index', 'store', 'update']);
    
    // 👥 Étudiants
    Route::get('/students', [StudentController::class, 'index']);
    Route::post('/students', [StudentController::class, 'store']);
    Route::delete('/students/{id}', [StudentController::class, 'destroy']);
    
    // 📚 Cours
    Route::apiResource('courses', CourseController::class)->only(['index', 'store', 'update', 'destroy']);
    
    // 📄 Bulletin
    Route::get('/bulletin/download', [BulletinController::class, 'download']);
    
    // 📊 Statistiques
    Route::get('/stats', [\App\Http\Controllers\StatsController::class, 'index']);
    
    // 🏛️ Délibération
    Route::post('/deliberation/submit', [\App\Http\Controllers\DeliberationController::class, 'submitGrades']);
    Route::post('/deliberation/deliberate', [\App\Http\Controllers\DeliberationController::class, 'deliberateGrades']);
    
    // 👤 Profil utilisateur
    Route::get('/profile', function(\Illuminate\Http\Request $request) {
        $user = $request->user()->load('role');
        if ($user->isEtudiant()) {
            $user->load('student');
        }
        return response()->json($user);
    });
    
    // 🔒 Changer mot de passe
    Route::post('/change-password', [\App\Http\Controllers\PasswordController::class, 'change']);
    
    // 🔍 Debug
    Route::get('/debug/user', [\App\Http\Controllers\DebugController::class, 'checkUser']);
});
