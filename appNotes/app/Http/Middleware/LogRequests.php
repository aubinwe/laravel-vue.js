<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class LogRequests
{
    public function handle(Request $request, Closure $next)
    {
        $start = microtime(true);
        
        // Affichage direct dans la console avec flush
        $output = "\n[" . date('H:i:s') . "] " . $request->method() . " " . $request->getPathInfo();
        
        if ($request->has('email')) {
            $output .= " (Login: " . $request->input('email') . ")";
        }
        
        echo $output;
        flush();
        
        $response = $next($request);
        
        $duration = round((microtime(true) - $start) * 1000, 2);
        echo " -> " . $response->getStatusCode() . " (" . $duration . "ms)";
        flush();
        
        return $response;
    }
}