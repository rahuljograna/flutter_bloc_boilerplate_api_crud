<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use JWTAuth;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Hashing\BcryptHasher;
use Illuminate\Support\Facades\Hash;
use Validator;

class UserController extends Controller
{
    public function login(Request $request){
        $validator = Validator::make($request->all(), [
            'email' => 'required',
            'password'=>'required'
        ]);
        if ($validator->fails()) {
            $response = [
                'success' => false,
                'message' => 'Validation Error.', $validator->errors(),
                'status'=> 500
            ];
            return response()->json($response, 404);
        }
        // Get User by email
        $user = User::where('email', $request->email)->first();

        // Return error message if user not found.
        if(!$user) return response()->json(['error' => 'User not found.', 'success' => false,], 404);

        // Account Validation
        if (!(new BcryptHasher)->check($request->input('password'), $user->password)) {
            // Return Error message if password is incorrect
            return response()->json(['error' => 'Email or password is incorrect. Authentication failed.','success' => false], 401);
        }

        // Get email and password from Request
        $credentials = $request->only('email', 'password');

        try {
            JWTAuth::factory()->setTTL(40320); // Expired Time 28days

            if (! $token = JWTAuth::attempt($credentials, ['exp' => Carbon::now()->addDays(28)->timestamp])) {

                return response()->json(['error' => 'invalid_credentials', 'success' => false], 401);

            }
        } catch (JWTException $e) {
            // Return Error message if cannot create token.
            return response()->json(['error' => 'could_not_create_token','success' => false], 500);

        }

        // transform user data
        // $data = new UserResource($user);

        // return response()->json(compact('token', 'data'));
        $response = [
            'token'=>$token,
            'user'=>$user,
            'success' => true,
            'status' => 200,
        ];
        return response()->json($response, 200);
    }

    public function register(Request $request){
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'email' => 'required',
            'password' => 'required',

        ]);
        if ($validator->fails()) {
            $response = [
                'success' => false,
                'message' => 'Validation Error.', $validator->errors(),
                'status'=> 500
            ];
            return response()->json($response, 404);
        }
        $emailValidation = User::where('email',$request->email)->first();
        if (is_null($emailValidation) || !$emailValidation) {
                $user = User::create([
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'name'=>$request->name
            ]);
            $token = JWTAuth::fromUser($user);
            return response()->json(['user'=>$user,'token'=>$token,'status'=>200,'success' => true], 200);
        }

        $response = [
            'success' => false,
            'message' => 'Email is already taken',
            'status' => 500
        ];
        return response()->json($response, 500);
    }

    public function logout(){
        auth()->logout();

        return response()
            ->json(['message' => 'Successfully logged out','status'=>200,'success' => true]);
    }
}
