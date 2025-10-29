<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Grade;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\View;
use Symfony\Component\HttpFoundation\Response;

class BulletinController extends Controller
{
    public function adminStudentBulletin(User $student): Response
    {
        abort_if($student->role !== 'user', 404);
        return $this->makeBulletinResponse($student);
    }

    public function myBulletin(Request $request): Response
    {
        $user = $request->user();
        return $this->makeBulletinResponse($user);
    }

    protected function makeBulletinResponse(User $student): Response
    {
        $grades = Grade::with(['subject:id,name,coefficient'])
            ->where('user_id', $student->id)
            ->orderBy('id','desc')->get();

        $sum = 0; $coef = 0;
        foreach ($grades as $g) { $c = $g->subject?->coefficient ?? 1; $sum += (float)$g->score * $c; $coef += $c; }
        $avg = $coef > 0 ? round($sum / $coef, 2) : null;

        $html = View::make('pdf.bulletin', [
            'student' => $student,
            'grades' => $grades,
            'average' => $avg,
        ])->render();

        // If DomPDF is installed, stream PDF; otherwise, return HTML
        if (class_exists(\Barryvdh\DomPDF\Facade\Pdf::class)) {
            $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadHTML($html);
            return $pdf->download('bulletin_'.$student->id.'.pdf');
        }
        return response($html, 200, ['Content-Type' => 'text/html']);
    }
}
