part of 'AuthBloc.dart';

// Estados de autenticación
abstract class AuthState {}

abstract class AuthActionState extends AuthState {}

// Estado inicial
class AuthInitial extends AuthState {}

// Estado de carga
class AuthLoadingState extends AuthState {}

// Estado autenticado
class AuthAuthenticatedState extends AuthState {
  final UserDataModel user;

  AuthAuthenticatedState({required this.user});
}

// Estado no autenticado
class AuthUnauthenticatedState extends AuthState {}

// Estados de acción
class AuthLoginSuccessActionState extends AuthActionState {
  final String message;

  AuthLoginSuccessActionState({required this.message});
}

class AuthRegisterSuccessActionState extends AuthActionState {
  final String message;

  AuthRegisterSuccessActionState({required this.message});
}

class AuthErrorActionState extends AuthActionState {
  final String error;

  AuthErrorActionState({required this.error});
}

class AuthLogoutSuccessActionState extends AuthActionState {
  final String message;

  AuthLogoutSuccessActionState({required this.message});
}
