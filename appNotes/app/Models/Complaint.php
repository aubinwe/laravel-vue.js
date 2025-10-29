<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Complaint extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'grade_id', 'message', 'status', 'admin_notes',
    ];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }

    public function grade(): BelongsTo { return $this->belongsTo(Grade::class); }
}
