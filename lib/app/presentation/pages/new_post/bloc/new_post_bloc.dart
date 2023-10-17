import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_boilerplate/app/core/config/api.service.dart';
import 'package:flutter_bloc_boilerplate/app/core/models/post_model.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/auth_repository.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/post_repository.dart';
import 'package:flutter_bloc_boilerplate/app/core/validations/new_post_form.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';

part 'new_post_event.dart';
part 'new_post_state.dart';

class NewPostBloc extends Bloc<NewPostEvent, NewPostState> {
  NewPostBloc() : super(const NewPostState()) {
    on<NewPostInitialEvent>(_onNewPostInitialEvent);

    on<OnPostImagePickerEvent>(_onPostImagePickerEvent);

    on<PostTitleChanged>(_onTitleChanged);

    on<PostTitleUnfocused>(_onTitleUnfocused);

    on<PostDescriptionChanged>(_onDescriptionChanged);

    on<PostDescriptionUnfocused>(_onDescriptionUnfocused);

    on<PostFormSubmitted>(_onPostFormSubmitted);
  }

  Future<void> _onNewPostInitialEvent(
      NewPostInitialEvent event, Emitter<NewPostState> emit) async {
    debugPrint('is New? ${event.action}, and the id ${event.postModel.id}');
    if (event.action == 'update') {
      debugPrint('update');
      emit(
        state.copyWith(
          title: PostTitleField.pure(event.postModel.title!),
          description: PostDescriptionField.pure(event.postModel.description!),
          cover: PostCover.pure(event.postModel.cover!),
          isValid: Formz.validate([
            state.title,
            state.description,
            state.cover,
          ]),
        ),
      );
    }
  }

  Future<void> _onPostImagePickerEvent(
      OnPostImagePickerEvent event, Emitter<NewPostState> emit) async {
    debugPrint(event.kind.toString());
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: event.kind == 'gallery'
              ? ImageSource.gallery
              : ImageSource.camera,
          imageQuality: 25);
      debugPrint(pickedFile.toString());
      if (pickedFile != null) {
        // emit(UploadingImageState());
        HttpResponse response = await PostRepository().uploadImage(pickedFile);
        debugPrint('response status code ${response.statusCode.toString()}');
        if (response.errorType == NetErrorType.none) {
          debugPrint(response.body.toString());
          Map<String, dynamic>? myMap =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (myMap.containsKey('data')) {
            debugPrint('ok');
            if (myMap['data']['image_name'] != null &&
                myMap['data']['image_name'].toString().isNotEmpty) {
              String url = myMap['data']['image_name'];
              debugPrint("URL => $url");
              final cover = PostCover.dirty(url);
              emit(
                state.copyWith(
                  cover: cover.isValid ? cover : PostCover.pure(url),
                  isValid:
                      Formz.validate([cover, state.title, state.description]),
                ),
              );
            }
          } else {
            debugPrint('Not OK');
          }
        } else {
          emit(state.copyWith(
              status: AddPostStatus.failure,
              toastMessage: 'Something went wrong'));
        }
      }
    } catch (e) {
      debugPrint('catch the error ${e.toString()}');
      emit(state.copyWith(
          status: AddPostStatus.failure, toastMessage: e.toString()));
    }
  }

  Future<void> _onTitleChanged(
      PostTitleChanged event, Emitter<NewPostState> emit) async {
    final title = PostTitleField.dirty(event.title);
    emit(
      state.copyWith(
        title: title.isValid ? title : PostTitleField.pure(event.title),
        status: AddPostStatus.initial,
        isValid: Formz.validate([title, state.cover, state.description]),
      ),
    );
  }

  Future<void> _onTitleUnfocused(
      PostTitleUnfocused event, Emitter<NewPostState> emit) async {
    final title = PostTitleField.dirty(state.title.value);
    emit(
      state.copyWith(
        title: title,
        status: AddPostStatus.initial,
        isValid: Formz.validate([title, state.cover, state.description]),
      ),
    );
  }

  Future<void> _onDescriptionChanged(
      PostDescriptionChanged event, Emitter<NewPostState> emit) async {
    final description = PostDescriptionField.dirty(event.description);
    emit(
      state.copyWith(
        description: description.isValid
            ? description
            : PostDescriptionField.pure(event.description),
        status: AddPostStatus.initial,
        isValid: Formz.validate([description, state.cover, state.title]),
      ),
    );
  }

  Future<void> _onDescriptionUnfocused(
      PostDescriptionUnfocused event, Emitter<NewPostState> emit) async {
    final description = PostDescriptionField.dirty(state.description.value);
    emit(
      state.copyWith(
        description: description,
        status: AddPostStatus.initial,
        isValid: Formz.validate([description, state.cover, state.title]),
      ),
    );
  }

  Future<void> _onPostFormSubmitted(
      PostFormSubmitted event, Emitter<NewPostState> emit) async {
    final title = PostTitleField.dirty(state.title.value);
    final description = PostDescriptionField.dirty(state.description.value);
    final cover = PostCover.dirty(state.cover.value);
    emit(
      state.copyWith(
        title: title,
        description: description,
        cover: cover,
        status: AddPostStatus.initial,
        isValid: Formz.validate([
          title,
          description,
          cover,
        ]),
      ),
    );
    if (state.isValid) {
      debugPrint('ok Submit');
      if (event.action == 'create') {
        debugPrint('create');
        emit(state.copyWith(status: AddPostStatus.submitting));
        try {
          var param = {
            "cover": state.cover.value.toString(),
            "title": state.title.value.toString(),
            "description": state.description.value.toString(),
            "user_id": AuthRepository.userId,
            "status": 1,
          };
          HttpResponse response = await PostRepository().createPost(param);
          debugPrint(response.statusCode.toString());
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(
              status: AddPostStatus.success,
              toastMessage: 'Post Saved',
            ));
          } else if (response.statusCode == 500) {
            Map<String, dynamic>? myMap =
                jsonDecode(response.body) as Map<String, dynamic>;
            if (myMap.containsKey('success') &&
                myMap.containsKey('message') &&
                myMap['success'] == false) {
              emit(state.copyWith(
                status: AddPostStatus.failure,
                toastMessage: myMap['message'].toString(),
              ));
            } else {
              debugPrint('API ERROR in 500-> ${response.body.toString()}');
              emit(
                state.copyWith(
                    status: AddPostStatus.failure,
                    toastMessage: 'Something went wrong'),
              );
            }
          } else {
            debugPrint('API ERROR-> ${response.body.toString()}');
            emit(
              state.copyWith(
                  status: AddPostStatus.failure,
                  toastMessage: 'Something went wrong'),
            );
          }
        } catch (e) {
          debugPrint('Catch Error ${e.toString()}');
          emit(state.copyWith(status: AddPostStatus.failure));
        }
      } else {
        debugPrint('update');
        emit(state.copyWith(status: AddPostStatus.submitting));
        try {
          var param = {
            "cover": state.cover.value.toString(),
            "title": state.title.value.toString(),
            "description": state.description.value.toString(),
            "id": event.postModel.id
          };
          HttpResponse response = await PostRepository().updatePost(param);
          debugPrint(response.statusCode.toString());
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(
              status: AddPostStatus.success,
              toastMessage: 'Post Updated',
            ));
          } else if (response.statusCode == 500) {
            Map<String, dynamic>? myMap =
                jsonDecode(response.body) as Map<String, dynamic>;
            if (myMap.containsKey('success') &&
                myMap.containsKey('message') &&
                myMap['success'] == false) {
              emit(state.copyWith(
                status: AddPostStatus.failure,
                toastMessage: myMap['message'].toString(),
              ));
            } else {
              debugPrint('API ERROR in 500-> ${response.body.toString()}');
              emit(
                state.copyWith(
                    status: AddPostStatus.failure,
                    toastMessage: 'Something went wrong'),
              );
            }
          } else {
            debugPrint('API ERROR-> ${response.body.toString()}');
            emit(
              state.copyWith(
                  status: AddPostStatus.failure,
                  toastMessage: 'Something went wrong'),
            );
          }
        } catch (e) {
          debugPrint('Catch Error ${e.toString()}');
          emit(state.copyWith(status: AddPostStatus.failure));
        }
      }
    }
  }
}
