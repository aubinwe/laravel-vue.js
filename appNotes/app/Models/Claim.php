<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Claim extends Model
{
    protected $fillable = ['grade_id', 'commentaire', 'statut', 'created_by'];

    public function grade()
    {
        return $this->belongsTo(Grade::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}