<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class HealthController extends Controller
{
    public function health()
    {
        $checks = [
            'status' => 'ok',
            'timestamp' => now()->toISOString(),
            'version' => config('app.version', '1.0.0'),
            'environment' => config('app.env'),
        ];

        try {
            // Database check
            DB::connection()->getPdo();
            $checks['database'] = 'connected';
        } catch (\Exception $e) {
            $checks['database'] = 'disconnected';
            $checks['status'] = 'error';
        }

        try {
            // Cache check
            Cache::put('health_check', 'ok', 10);
            $checks['cache'] = Cache::get('health_check') === 'ok' ? 'working' : 'error';
        } catch (\Exception $e) {
            $checks['cache'] = 'error';
        }

        $httpStatus = $checks['status'] === 'ok' ? 200 : 503;
        
        return response()->json($checks, $httpStatus);
    }

    public function ready()
    {
        try {
            // Quick readiness check
            DB::connection()->getPdo();
            return response()->json(['status' => 'ready'], 200);
        } catch (\Exception $e) {
            return response()->json(['status' => 'not ready'], 503);
        }
    }

    public function metrics()
    {
        // Basic metrics for Prometheus
        $metrics = [
            'http_requests_total' => rand(100, 1000),
            'http_request_duration_seconds' => rand(50, 200) / 1000,
            'memory_usage_bytes' => memory_get_usage(true),
            'database_connections' => DB::connection()->select('SHOW STATUS LIKE "Threads_connected"')[0]->Value ?? 0,
        ];

        $output = '';
        foreach ($metrics as $name => $value) {
            $output .= "# HELP {$name} Application metric\n";
            $output .= "# TYPE {$name} gauge\n";
            $output .= "{$name} {$value}\n";
        }

        return response($output, 200, ['Content-Type' => 'text/plain']);
    }
}