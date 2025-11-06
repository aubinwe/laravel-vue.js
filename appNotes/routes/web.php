<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MetricsController;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/metrics', [MetricsController::class, 'metrics']);