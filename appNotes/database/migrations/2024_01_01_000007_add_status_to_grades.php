<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('grades', function (Blueprint $table) {
            $table->enum('statut', ['en_cours', 'soumis', 'delibere'])->default('en_cours');
        });
    }

    public function down()
    {
        Schema::table('grades', function (Blueprint $table) {
            $table->dropColumn('statut');
        });
    }
};