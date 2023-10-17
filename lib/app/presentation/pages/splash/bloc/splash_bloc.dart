import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/auth_repository.dart';
import 'package:flutter_bloc_boilerplate/app/core/repositories/splash_respository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepositry _splashRepositry = SplashRepositry();
  SplashBloc() : super(const SplashState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);
  }

  Future<void> _onSplashInitialEvent(
      SplashInitialEvent event, Emitter<SplashState> emit) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);

    emit(state.copyWith(status: SplashStatus.loading));
    String? userToken = await _splashRepositry.userAuthToken();
    if (userToken != null) {
      debugPrint('Authorized');
      AuthRepository().init();
      emit(state.copyWith(status: SplashStatus.authorized));
    } else {
      debugPrint('UnAuthorized');
      emit(state.copyWith(status: SplashStatus.unAuthorized));
    }

    if (!hasInternet) {
      debugPrint('No Internet Connection');
      emit(state.copyWith(
        status: SplashStatus.failure,
        toastMessage: 'No Internet Connection',
      ));
    }
  }
}
