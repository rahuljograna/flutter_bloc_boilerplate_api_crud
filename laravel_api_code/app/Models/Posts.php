<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Posts extends Model
{
    use HasFactory;

    public $table = "post";

    public $timestamps = true; //by default timestamp false

    protected $fillable = [
        'user_id','title','description','cover','status'
    ];
}
