<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PostsController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('auth/login', [UserController::class, 'login']);
Route::post('auth/register', [UserController::class, 'register']);

Route::post('post/uploadImage', [PostsController::class, 'uploadImage']);


Route::group(['middleware' => ['jwt', 'jwt.auth']], function () {
    Route::post('auth/logout', [UserController::class, 'logout']);

    // Post Routes
    Route::post('post/save', [PostsController::class, 'save']);
    Route::put('post/update', [PostsController::class, 'update']);
    Route::delete('post/delete/{id}', [PostsController::class, 'delete']);
    Route::post('post/getByUser', [PostsController::class, 'getByUser']);
});
