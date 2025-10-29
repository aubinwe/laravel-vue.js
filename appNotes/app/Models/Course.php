<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    protected $fillable = ['name', 'code', 'coefficient', 'professor_id'];
    
    public $timestamps = false;

    public function professor()
    {
        return $this->belongsTo(User::class, 'professor_id');
    }

    public function grades()
    {
        return $this->hasMany(Grade::class);
    }
}