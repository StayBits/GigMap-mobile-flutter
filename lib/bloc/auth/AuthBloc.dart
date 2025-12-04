import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gigmap_mobile_flutter/repository/AuthRepository.dart';
import 'package:gigmap_mobile_flutter/services/TokenStorage.dart';
import 'package:gigmap_mobile_flutter/models/UserDataModel.dart';
import 'package:gigmap_mobile_flutter/models/AuthResponse.dart';

part 'AuthState.dart';
part 'AuthEvent.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckEvent>(authCheckEvent);
    on<AuthLoginEvent>(authLoginEvent);
    on<AuthRegisterEvent>(authRegisterEvent);
    on<AuthLogoutEvent>(authLogoutEvent);
  }


  Future<void> authCheckEvent(
      AuthCheckEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      bool isAuthenticated = await TokenStorage.isAuthenticated();

      if (!isAuthenticated) {
        emit(AuthUnauthenticatedState());
        return;
      }

      UserDataModel? user = await TokenStorage.getUserData();

      if (user != null) {
        emit(AuthAuthenticatedState(user: user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (_) {
      emit(AuthUnauthenticatedState());
    }
  }


  Future<void> authLoginEvent(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      AuthResponse? res = await AuthRepository.login(
        emailOrUsername: event.emailOrUsername,
        password: event.password,
      );

      if (res == null) {
        emit(AuthUnauthenticatedState());
        emit(AuthErrorActionState(error: "Credenciales inválidas"));
        return;
      }

      await TokenStorage.saveAuthData(res);


      final user = UserDataModel(
        id: res.id,
        email: res.email,
        username: res.username,
        name: "",
        role: res.role ?? "",
        image: "",
        isArtist: res.isArtist,
      );

      emit(AuthAuthenticatedState(user: user));
      emit(AuthLoginSuccessActionState(message: res.message));
    } catch (e) {
      emit(AuthUnauthenticatedState());
      emit(AuthErrorActionState(error: "Error de conexión"));
    }
  }


  Future<void> authRegisterEvent(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      AuthResponse? res = await AuthRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        role: event.role,
      );

      if (res == null) {
        emit(AuthUnauthenticatedState());
        emit(AuthErrorActionState(error: "Error en el registro"));
        return;
      }

      await TokenStorage.saveAuthData(res);


      final user = UserDataModel(
        id: res.id,
        email: res.email,
        username: res.username,
        name: "",
        role: res.role ?? "",
        image: "",
        isArtist: res.isArtist,
      );

      emit(AuthAuthenticatedState(user: user));
      emit(AuthRegisterSuccessActionState(message: res.message));
    } catch (e) {
      emit(AuthUnauthenticatedState());
      emit(AuthErrorActionState(error: "Error de conexión"));
    }
  }


  Future<void> authLogoutEvent(
      AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      await TokenStorage.clearAuthData();
      emit(AuthUnauthenticatedState());
      emit(AuthLogoutSuccessActionState(message: "Sesión cerrada exitosamente"));
    } catch (e) {
      emit(AuthErrorActionState(error: "Error al cerrar sesión"));
    }
  }
}
