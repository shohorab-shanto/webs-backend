<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Ticket;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function index(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return $ticket->messages()->with('user')->latest()->paginate(50);
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

        $message = Message::create([
            'ticket_id' => $ticket->id,
            'user_id' => $user->id,
            'body' => $validated['body'],
        ]);

        // Real-time hook can be added here (broadcast event, pusher, etc.)
        return response()->json($message->load('user'), 201);
    }
}
