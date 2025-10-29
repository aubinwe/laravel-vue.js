<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Grade extends Model
{
    protected $fillable = ['student_id', 'course_id', 'note', 'semestre'];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function course()
    {
        return $this->belongsTo(Course::class);
    }

    public function claims()
    {
        return $this->hasMany(Claim::class);
    }

    public function deliberation()
    {
        return $this->hasOne(Deliberation::class);
    }
}