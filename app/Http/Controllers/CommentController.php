<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use App\Models\Ticket;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    public function index(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return $ticket->comments()->with('user')->latest()->paginate(50);
    }

    public function store(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'body' => 'required|string',
        ]);

        $comment = Comment::create([
            'ticket_id' => $ticket->id,
            'user_id' => $user->id,
            'body' => $validated['body'],
        ]);

        return response()->json($comment->load('user'), 201);
    }
}
