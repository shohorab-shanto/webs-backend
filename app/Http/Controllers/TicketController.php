<?php

namespace App\Http\Controllers;

use App\Models\Ticket;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TicketController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role === 'admin') {
            return Ticket::with('user')->latest()->paginate(20);
        }
        return Ticket::with('user')->where('user_id', $user->id)->latest()->paginate(20);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'subject' => 'required|string|max:255',
            'description' => 'required|string',
            'category' => 'nullable|string|max:255',
            'priority' => 'in:low,medium,high,urgent',
            'attachment' => 'nullable|file|max:5120',
        ]);

        $path = null;
        if ($request->hasFile('attachment')) {
            $path = $request->file('attachment')->store('attachments', 'public');
        }

        $ticket = Ticket::create([
            'user_id' => $request->user()->id,
            'subject' => $validated['subject'],
            'description' => $validated['description'],
            'category' => $validated['category'] ?? null,
            'priority' => $validated['priority'] ?? 'medium',
            'status' => 'open',
            'attachment' => $path,
        ]);

        return response()->json($ticket->load('user'), 201);
    }

    public function show(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return $ticket->load('user');
    }

    public function update(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $validated = $request->validate([
            'subject' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'category' => 'nullable|string|max:255',
            'priority' => 'in:low,medium,high,urgent',
            'status' => 'in:open,in_progress,resolved,closed',
            'attachment' => 'nullable|file|max:5120',
        ]);

        if ($request->hasFile('attachment')) {
            if ($ticket->attachment) {
                Storage::disk('public')->delete($ticket->attachment);
            }
            $ticket->attachment = $request->file('attachment')->store('attachments', 'public');
        }

        $ticket->fill($validated)->save();
        return response()->json($ticket->refresh());
    }

    public function destroy(Request $request, Ticket $ticket)
    {
        $user = $request->user();
        if ($user->role !== 'admin' && $ticket->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        if ($ticket->attachment) {
            Storage::disk('public')->delete($ticket->attachment);
        }
        $ticket->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
