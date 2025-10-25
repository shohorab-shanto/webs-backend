<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TicketController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\MessageController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('tickets', TicketController::class);

    Route::get('tickets/{ticket}/comments', [CommentController::class, 'index']);
    Route::post('tickets/{ticket}/comments', [CommentController::class, 'store']);

    Route::get('tickets/{ticket}/messages', [MessageController::class, 'index']);
    Route::post('tickets/{ticket}/messages', [MessageController::class, 'store']);
});