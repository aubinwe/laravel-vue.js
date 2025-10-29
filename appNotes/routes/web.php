<?php

use Illuminate\Support\Facades\Route;

// SPA Vue en page d'accueil et fallback
Route::view('/', 'app');
Route::view('/{any}', 'app')->where('any', '.*');
