<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Deliberation extends Model
{
    protected $fillable = ['grade_id', 'note_finale', 'statut_validation', 'validated_by'];

    public function grade()
    {
        return $this->belongsTo(Grade::class);
    }

    public function validator()
    {
        return $this->belongsTo(User::class, 'validated_by');
    }
}