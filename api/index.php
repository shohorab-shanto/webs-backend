<?php
// api/index.php

require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';

use Illuminate\Http\Request;
use Illuminate\Foundation\Application;

$app->handleRequest(Request::capture());
