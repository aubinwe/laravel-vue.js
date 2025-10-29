<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Note;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class NoteController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role === 'admin') {
            $notes = Note::with('user:id,name')->latest()->paginate(10);
        } else {
            $notes = Note::with('user:id,name')->where('user_id', $user->id)->latest()->paginate(10);
        }
        return response()->json($notes);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => ['required','string','max:255'],
            'content' => ['nullable','string'],
        ]);
        $note = Note::create([
            'title' => $data['title'],
            'content' => $data['content'] ?? null,
            'user_id' => $request->user()->id,
        ]);
        return response()->json($note, 201);
    }

    public function show(Request $request, Note $note)
    {
        $this->authorize('view', $note);
        return response()->json($note->load('user:id,name'));
    }

    public function update(Request $request, Note $note)
    {
        $this->authorize('update', $note);
        $data = $request->validate([
            'title' => ['sometimes','required','string','max:255'],
            'content' => ['nullable','string'],
        ]);
        $note->update($data);
        return response()->json($note);
    }

    public function destroy(Request $request, Note $note)
    {
        $this->authorize('delete', $note);
        $note->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
