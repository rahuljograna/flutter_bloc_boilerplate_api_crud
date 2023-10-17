import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc_boilerplate/app/env.dart';

enum NetErrorType {
  none,
  disconnected,
  timedOut,
  denied,
  unknown,
}

typedef HttpRequest = Future<http.Response> Function();

class HttpClient {
  static const String appBaseUrl = Environments.apiBaseURL;
  static int timeoutInSeconds = 30;

  Future<HttpResponse> getPublic(String endpoint,
      {Map<String, String>? headers}) async {
    return await _request(() async {
      return await http
          .get(Uri.parse(appBaseUrl + endpoint), headers: headers)
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> putPublic(
    String endpoint,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    return await _request(() async {
      return await http
          .put(
            Uri.parse(appBaseUrl + endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> deletePublic(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return await _request(() async {
      return await http
          .delete(
            Uri.parse(appBaseUrl + endpoint),
            headers: headers,
          )
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> postPublic(
    String endpoint,
    dynamic body,
  ) async {
    return await _request(() async {
      return await http
          .post(
            Uri.parse(appBaseUrl + endpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> getPrivate(String endpoint, String token) async {
    return await _request(() async {
      return await http.get(Uri.parse(appBaseUrl + endpoint), headers: {
        'Content-Type': 'application/json;',
        'Authorization': 'Bearer $token'
      }).timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> putPrivate(
      String endpoint, dynamic body, String token) async {
    return await _request(() async {
      return await http
          .put(
            Uri.parse(appBaseUrl + endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> deletePrivate(
    String endpoint,
    String token,
  ) async {
    return await _request(() async {
      return await http.delete(
        Uri.parse(appBaseUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> postPrivate(
      String endpoint, dynamic body, String token) async {
    return await _request(() async {
      return await http
          .post(
            Uri.parse(appBaseUrl + endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
    });
  }

  Future<HttpResponse> uploadFiles(
    String endpoint,
    List<MultipartBody> multipartBody,
  ) async {
    return await _request(() async {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(appBaseUrl + endpoint));
      for (MultipartBody multipart in multipartBody) {
        File file = File(multipart.file.path);
        request.files.add(http.MultipartFile(
          multipart.key,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
      http.Response response =
          await http.Response.fromStream(await request.send());
      return response;
    });
  }

  Future<HttpResponse> _request(HttpRequest request) async {
    try {
      return HttpResponse(await request());
    } on Exception catch (e) {
      debugPrint("Network call failed. error = ${e.toString()}");
      return HttpResponse.error();
    }
  }
}

class HttpResponse {
  final http.Response raw;

  NetErrorType errorType = NetErrorType.none;

  bool get success => errorType == NetErrorType.none;

  String get body => raw.body;

  Map<String, String> get headers => raw.headers;

  int get statusCode => raw.statusCode;

  HttpResponse(this.raw) {
    //200 means all is good :)
    if (raw.statusCode == 200) {
      errorType = NetErrorType.none;
    } else if (raw.statusCode >= 500 && raw.statusCode < 600) {
      errorType = NetErrorType.timedOut;
    } else if (raw.statusCode >= 400 && raw.statusCode < 500) {
      errorType = NetErrorType.denied;
    } else {
      errorType = NetErrorType.unknown;
    }
  }

  HttpResponse.error()
      : raw = http.Response("", -1),
        errorType = NetErrorType.unknown;

  HttpResponse.empty()
      : raw = http.Response("", 200),
        errorType = NetErrorType.none;
}

class MultipartBody {
  String key;
  XFile file;

  MultipartBody(this.key, this.file);
}
