part of 'AuthBloc.dart';

// Eventos de autenticación
abstract class AuthEvent {}

// Evento para iniciar login
class AuthLoginEvent extends AuthEvent {
  final String emailOrUsername;
  final String password;

  AuthLoginEvent({
    required this.emailOrUsername,
    required this.password,
  });
}

// Evento para iniciar registro
class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String username;
  final String password;
  final String role;

  AuthRegisterEvent({
    required this.email,
    required this.username,
    required this.password,
    required this.role,
  });
}

// Evento para verificar autenticación inicial
class AuthCheckEvent extends AuthEvent {}

// Evento para logout
class AuthLogoutEvent extends AuthEvent {}
