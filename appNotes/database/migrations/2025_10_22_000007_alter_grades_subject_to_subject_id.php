<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('grades')) return;
        Schema::table('grades', function (Blueprint $table) {
            if (!Schema::hasColumn('grades','subject_id')) {
                $table->unsignedBigInteger('subject_id')->nullable()->after('user_id');
            }
        });

        // Try to migrate existing textual subjects to Subject entities and set subject_id
        if (Schema::hasColumn('grades','subject')) {
            $subjects = DB::table('grades')->select('subject')->distinct()->pluck('subject')->filter();
            foreach ($subjects as $name) {
                $existing = DB::table('subjects')->where('name', $name)->first();
                if (!$existing) {
                    DB::table('subjects')->insert(['name'=>$name,'coefficient'=>1,'created_at'=>now(),'updated_at'=>now()]);
                    $existing = DB::table('subjects')->where('name',$name)->first();
                }
                DB::table('grades')->where('subject',$name)->update(['subject_id'=>$existing->id]);
            }
        }

        Schema::table('grades', function (Blueprint $table) {
            if (Schema::hasColumn('grades','subject_id')) {
                $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            }
        });

        // Finally, drop textual column if exists
        Schema::table('grades', function (Blueprint $table) {
            if (Schema::hasColumn('grades','subject')) {
                $table->dropColumn('subject');
            }
        });

        // Ensure subject_id not null
        Schema::table('grades', function (Blueprint $table) {
            $table->unsignedBigInteger('subject_id')->nullable(false)->change();
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('grades')) return;
        Schema::table('grades', function (Blueprint $table) {
            if (!Schema::hasColumn('grades','subject')) {
                $table->string('subject')->nullable()->after('user_id');
            }
        });
        // Optionally backfill subject names from related subject table
        $rows = DB::table('grades')->select('id','subject_id')->get();
        foreach ($rows as $r) {
            $name = optional(DB::table('subjects')->where('id',$r->subject_id)->first())->name;
            DB::table('grades')->where('id',$r->id)->update(['subject'=>$name]);
        }
        Schema::table('grades', function (Blueprint $table) {
            if (Schema::hasColumn('grades','subject_id')) {
                $table->dropForeign(['subject_id']);
                $table->dropColumn('subject_id');
            }
        });
    }
};
