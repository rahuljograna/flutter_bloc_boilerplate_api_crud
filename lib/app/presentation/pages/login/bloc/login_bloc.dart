import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_boilerplate/app/core/config/api.service.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/auth_repository.dart';
import 'package:flutter_bloc_boilerplate/app/core/validations/login_form.dart';
import 'package:formz/formz.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository = AuthRepository();
  LoginBloc() : super(LoginInitial()) {
    on<LoginEmailChanged>(_onLoginEmailChanged);
    on<LoginPasswordChanged>(_onLoginPasswordChanged);
    on<LoginEmailUnfocused>(_onLoginEmailUnfocused);
    on<LoginPasswordUnfocused>(_onLoginPasswordUnfocused);
    on<LoginFormSubmitted>(_onLoginFormSubmitted);
  }

  void _onLoginEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = LoginEmailField.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : LoginEmailField.pure(event.email),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void _onLoginPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = LoginPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        password: password.isValid
            ? password
            : LoginPasswordField.pure(event.password),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  void _onLoginEmailUnfocused(
      LoginEmailUnfocused event, Emitter<LoginState> emit) {
    final email = LoginEmailField.dirty(state.email.value);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void _onLoginPasswordUnfocused(
    LoginPasswordUnfocused event,
    Emitter<LoginState> emit,
  ) {
    final password = LoginPasswordField.dirty(state.password.value);
    emit(
      state.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> _onLoginFormSubmitted(
    LoginFormSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final email = LoginEmailField.dirty(state.email.value);
    final password = LoginPasswordField.dirty(state.password.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([email, password]),
      ),
    );
    if (state.isValid &&
        state.email.value.isNotEmpty &&
        state.password.value.isNotEmpty) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        var param = {
          "email": state.email.value.toString(),
          "password": state.password.value.toString(),
        };
        HttpResponse response =
            await _authRepository.loginWithEmailPassword(param);
        debugPrint(response.statusCode.toString());
        if (response.errorType == NetErrorType.none) {
          debugPrint('Login Success ${response.body.toString()}');
          Map<String, dynamic>? myMap =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (myMap.containsKey('token') && myMap.containsKey('user')) {
            _authRepository.saveToken(myMap['token'].toString(),
                int.parse(myMap['user']['id'].toString()));
            await _authRepository.init();
            emit(state.copyWith(status: FormzSubmissionStatus.success));
          } else {
            debugPrint('success maps issue');
            emit(state.copyWith(
                status: FormzSubmissionStatus.failure,
                toastMessage: 'Something went wrong'));
          }
        } else if (response.statusCode == 500) {
          Map<String, dynamic>? myMap =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (myMap.containsKey('success') &&
              myMap.containsKey('message') &&
              myMap['success'] == false) {
            emit(state.copyWith(
                status: FormzSubmissionStatus.failure,
                toastMessage: myMap['message'].toString()));
          } else {
            debugPrint('API ERROR in 500-> ${response.body.toString()}');
            emit(state.copyWith(
                status: FormzSubmissionStatus.failure,
                toastMessage: 'Something went wrong'));
          }
        } else {
          debugPrint('API ERROR-> ${response.body.toString()}');
          emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              toastMessage: 'Something went wrong'));
        }
      } catch (e) {
        debugPrint('catch login error ${e.toString()}');
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure, toastMessage: e.toString()));
      }
    }
  }
}
