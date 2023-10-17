import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_boilerplate/app/core/config/api.service.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/auth_repository.dart';
import 'package:flutter_bloc_boilerplate/app/core/validations/register_form.dart';
import 'package:formz/formz.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository = AuthRepository();

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterEmailChanged>(_onRegisterEmailChanged);
    on<RegisterPasswordChanged>(_onRegisterPasswordChanged);
    on<RegisterNameChanged>(_onRegisterNameChanged);
    on<RegisterConfirmPasswordChanged>(_onRegisterConfirmPasswordChanged);

    on<RegisterEmailUnfocused>(_onRegisterEmailUnfocused);
    on<RegisterPasswordUnfocused>(_onRegisterPasswordUnfocused);
    on<RegisterNameUnfocused>(_onRegisterNameUnfocused);
    on<RegisterConfirmPasswordUnfocused>(_onRegisterConfirmPasswordUnfocused);

    on<RegisterFormSubmitted>(_onRegisterFormSubmitted);
  }

  Future<void> _onRegisterEmailChanged(
      RegisterEmailChanged event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : RegisterEmailField.pure(event.email),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          email,
          state.password,
          state.name,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterPasswordChanged(
      RegisterPasswordChanged event, Emitter<RegisterState> emit) async {
    final password = RegisterPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        password: password.isValid
            ? password
            : RegisterPasswordField.pure(event.password),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          password,
          state.email,
          state.name,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterNameChanged(
      RegisterNameChanged event, Emitter<RegisterState> emit) async {
    final name = RegisterNameField.dirty(event.name);
    emit(
      state.copyWith(
        name: name.isValid ? name : RegisterNameField.pure(event.name),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          name,
          state.email,
          state.password,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterConfirmPasswordChanged(
      RegisterConfirmPasswordChanged event, Emitter<RegisterState> emit) async {
    final confirmedPassword = RegisterConfirmedPasswordField.dirty(
      password: state.confirmedPassword.value,
      value: event.password,
    );
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          confirmedPassword,
          state.password,
          state.name,
          state.email,
        ]),
      ),
    );
  }

  Future<void> _onRegisterEmailUnfocused(
      RegisterEmailUnfocused event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    emit(
      state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          email,
          state.password,
          state.name,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterPasswordUnfocused(
      RegisterPasswordUnfocused event, Emitter<RegisterState> emit) async {
    final password = RegisterPasswordField.dirty(state.password.value);
    emit(
      state.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          password,
          state.email,
          state.name,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterNameUnfocused(
      RegisterNameUnfocused event, Emitter<RegisterState> emit) async {
    final name = RegisterNameField.dirty(state.name.value);
    emit(
      state.copyWith(
        name: name,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          name,
          state.email,
          state.password,
          state.confirmedPassword,
        ]),
      ),
    );
  }

  Future<void> _onRegisterConfirmPasswordUnfocused(
      RegisterConfirmPasswordUnfocused event,
      Emitter<RegisterState> emit) async {
    final confirmedPassword = RegisterConfirmedPasswordField.dirty(
        password: state.password.value, value: state.confirmedPassword.value);
    emit(
      state.copyWith(
        confirmedPassword: confirmedPassword,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([
          confirmedPassword,
          state.email,
          state.password,
          state.name,
        ]),
      ),
    );
  }

  Future<void> _onRegisterFormSubmitted(
      RegisterFormSubmitted event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    final password = RegisterPasswordField.dirty(state.password.value);
    final name = RegisterNameField.dirty(state.name.value);
    final confirmPassword = RegisterConfirmedPasswordField.dirty(
        password: state.password.value, value: state.confirmedPassword.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        name: name,
        confirmedPassword: confirmPassword,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([email, password, name, confirmPassword]),
      ),
    );
    if (state.isValid) {
      debugPrint('Submit => ${state.email.value.toString()}');
      debugPrint('name => ${state.name.value}');
      debugPrint('password => ${state.password.value}');
      debugPrint('confirm => ${state.confirmedPassword.value}');
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        var param = {
          "email": state.email.value.toString(),
          "password": state.password.value.toString(),
          "name": state.name.value.toString()
        };
        HttpResponse response = await _authRepository.createAccount(param);
        debugPrint(response.statusCode.toString());
        if (response.errorType == NetErrorType.none) {
          debugPrint('Register Success ${response.body.toString()}');
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
