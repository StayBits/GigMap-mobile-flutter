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

  // Verificar si el usuario ya está autenticado al iniciar la app
  Future<void> authCheckEvent(
      AuthCheckEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      bool isAuthenticated = await TokenStorage.isAuthenticated();
      if (isAuthenticated) {
        UserDataModel? user = await TokenStorage.getUserData();
        if (user != null) {
          emit(AuthAuthenticatedState(user: user));
        } else {
          emit(AuthUnauthenticatedState());
        }
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(AuthUnauthenticatedState());
    }
  }

  // Manejar login
  Future<void> authLoginEvent(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      AuthResponse? response = await AuthRepository.login(
        emailOrUsername: event.emailOrUsername,
        password: event.password,
      );

      if (response != null) {
        // Guardar datos de autenticación
        await TokenStorage.saveAuthData(response);

        // Crear objeto UserDataModel
        UserDataModel user = UserDataModel(
          id: response.id,
          email: response.email,
          username: response.username,
          isArtist: response.isArtist,
          role: response.role,
        );

        emit(AuthAuthenticatedState(user: user));
        emit(AuthLoginSuccessActionState(message: response.message));
      } else {
        emit(AuthUnauthenticatedState());
        emit(AuthErrorActionState(error: 'Credenciales inválidas'));
      }
    } catch (e) {
      emit(AuthUnauthenticatedState());
      emit(AuthErrorActionState(error: 'Error de conexión'));
    }
  }

  // Manejar registro
  Future<void> authRegisterEvent(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      AuthResponse? response = await AuthRepository.register(
        email: event.email,
        username: event.username,
        password: event.password,
        role: event.role,
      );

      if (response != null) {
        // Guardar datos de autenticación
        await TokenStorage.saveAuthData(response);

        // Crear objeto UserDataModel
        UserDataModel user = UserDataModel(
          id: response.id,
          email: response.email,
          username: response.username,
          isArtist: response.isArtist,
          role: response.role,
        );

        emit(AuthAuthenticatedState(user: user));
        emit(AuthRegisterSuccessActionState(message: response.message));
      } else {
        emit(AuthUnauthenticatedState());
        emit(AuthErrorActionState(error: 'Error en el registro'));
      }
    } catch (e) {
      emit(AuthUnauthenticatedState());
      emit(AuthErrorActionState(error: 'Error de conexión'));
    }
  }

  // Manejar logout
  Future<void> authLogoutEvent(
      AuthLogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    try {
      await TokenStorage.clearAuthData();
      emit(AuthUnauthenticatedState());
      emit(AuthLogoutSuccessActionState(message: 'Sesión cerrada exitosamente'));
    } catch (e) {
      emit(AuthErrorActionState(error: 'Error al cerrar sesión'));
    }
  }
}
