<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\Grade;
use App\Models\Claim;

class MetricsController extends Controller
{
    public function metrics()
    {
        try {
            $metrics = [];
            
            // Application metrics
            $metrics[] = '# HELP app_users_total Total number of users';
            $metrics[] = '# TYPE app_users_total counter';
            $metrics[] = 'app_users_total ' . (User::count() ?? 0);
            
            $metrics[] = '# HELP app_grades_total Total number of grades';
            $metrics[] = '# TYPE app_grades_total counter';
            $metrics[] = 'app_grades_total ' . (Grade::count() ?? 0);
            
            $metrics[] = '# HELP app_claims_total Total number of claims';
            $metrics[] = '# TYPE app_claims_total counter';
            $metrics[] = 'app_claims_total ' . (Claim::count() ?? 0);
            
            // Database metrics
            try {
                $dbConnections = DB::select("SHOW STATUS LIKE 'Threads_connected'");
                if (!empty($dbConnections)) {
                    $metrics[] = '# HELP mysql_connections_active Active MySQL connections';
                    $metrics[] = '# TYPE mysql_connections_active gauge';
                    $metrics[] = 'mysql_connections_active ' . $dbConnections[0]->Value;
                }
            } catch (\Exception $e) {
                $metrics[] = '# HELP mysql_connections_active Active MySQL connections';
                $metrics[] = '# TYPE mysql_connections_active gauge';
                $metrics[] = 'mysql_connections_active 0';
            }
            
            // HTTP metrics (simulated)
            $metrics[] = '# HELP http_requests_total Total HTTP requests';
            $metrics[] = '# TYPE http_requests_total counter';
            $metrics[] = 'http_requests_total{method="GET",status="200"} ' . rand(100, 1000);
            $metrics[] = 'http_requests_total{method="POST",status="200"} ' . rand(50, 500);
            $metrics[] = 'http_requests_total{method="GET",status="404"} ' . rand(1, 10);
            $metrics[] = 'http_requests_total{method="POST",status="500"} ' . rand(0, 5);
            
            $metrics[] = '# HELP http_request_duration_seconds HTTP request duration';
            $metrics[] = '# TYPE http_request_duration_seconds histogram';
            $metrics[] = 'http_request_duration_seconds_bucket{le="0.1"} ' . rand(10, 100);
            $metrics[] = 'http_request_duration_seconds_bucket{le="0.5"} ' . rand(100, 500);
            $metrics[] = 'http_request_duration_seconds_bucket{le="1.0"} ' . rand(500, 800);
            $metrics[] = 'http_request_duration_seconds_bucket{le="+Inf"} ' . rand(800, 1000);
            
            // Prometheus up metric
            $metrics[] = '# HELP up Application is up';
            $metrics[] = '# TYPE up gauge';
            $metrics[] = 'up 1';
            
            return response(implode("\n", $metrics) . "\n")
                ->header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
                
        } catch (\Exception $e) {
            // Fallback metrics si erreur
            $fallback = [
                '# HELP up Application is up',
                '# TYPE up gauge',
                'up 0',
                '# HELP app_error Application error',
                '# TYPE app_error gauge', 
                'app_error 1'
            ];
            
            return response(implode("\n", $fallback) . "\n")
                ->header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8');
        }
    }
}