class ApiEndPoints {
  // Public API
  static const String registerAccount = 'api/auth/register';
  static const String loginWithEmailPassword = 'api/auth/login';
  static const String uploadImage = 'api/post/uploadImage';

  // Private API
  static const String logout = 'api/auth/logout';

  static const String getMyPost = 'api/post/getByUser';
  static const String createPost = 'api/post/save';
  static const String updatePost = 'api/post/update';
  static const String deletePost = 'api/post/delete';
}
