<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class MetricsMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $start = microtime(true);
        
        $response = $next($request);
        
        $duration = microtime(true) - $start;
        
        // Collecter les métriques
        $this->recordMetrics($request, $response, $duration);
        
        return $response;
    }
    
    private function recordMetrics($request, $response, $duration)
    {
        $method = $request->method();
        $status = $response->getStatusCode();
        $route = $request->route() ? $request->route()->getName() : 'unknown';
        
        // Incrémenter le compteur de requêtes
        $key = "metrics:http_requests_total:{$method}:{$status}:{$route}";
        Cache::increment($key, 1);
        
        // Enregistrer la durée
        $durationKey = "metrics:http_request_duration:{$method}:{$route}";
        $durations = Cache::get($durationKey, []);
        $durations[] = $duration;
        
        // Garder seulement les 100 dernières mesures
        if (count($durations) > 100) {
            $durations = array_slice($durations, -100);
        }
        
        Cache::put($durationKey, $durations, 3600);
    }
}