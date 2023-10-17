import 'package:flutter_bloc_boilerplate/app/core/config/api.service.dart';
import 'package:flutter_bloc_boilerplate/app/core/config/api_endpoints.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';

class PostRepository {
  final HttpClient _httpClient = HttpClient();
  Future<HttpResponse> createPost(dynamic param) async {
    HttpResponse response = await _httpClient.postPrivate(
        ApiEndPoints.createPost, param, AuthRepository.userToken);
    return response;
  }

  Future<HttpResponse> updatePost(dynamic param) async {
    HttpResponse response = await _httpClient.putPrivate(
        ApiEndPoints.updatePost, param, AuthRepository.userToken);
    return response;
  }

  Future<HttpResponse> deletePost(int id) async {
    HttpResponse response = await _httpClient.deletePrivate(
        '${ApiEndPoints.deletePost}/$id', AuthRepository.userToken);
    return response;
  }

  Future<HttpResponse> getMyPost() async {
    HttpResponse response = await _httpClient.postPrivate(
        ApiEndPoints.getMyPost,
        {
          "id": AuthRepository.userId,
        },
        AuthRepository.userToken);
    return response;
  }

  Future<HttpResponse> uploadImage(XFile data) async {
    HttpResponse response = await _httpClient
        .uploadFiles(ApiEndPoints.uploadImage, [MultipartBody('image', data)]);
    return response;
  }
}
