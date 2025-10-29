<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ExportController extends Controller
{
    public function studentsCsv(Request $request)
    {
        $user = $request->user();
        if ($user->role !== 'admin') {
            abort(403);
        }

        $filename = 'students.csv';
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"$filename\"",
        ];

        $response = new StreamedResponse(function () {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, ['id', 'name', 'email']);
            User::where('role', 'user')->orderBy('id')->chunk(500, function ($users) use ($handle) {
                foreach ($users as $u) {
                    fputcsv($handle, [$u->id, $u->name, $u->email]);
                }
            });
            fclose($handle);
        }, 200, $headers);

        return $response;
    }
}
