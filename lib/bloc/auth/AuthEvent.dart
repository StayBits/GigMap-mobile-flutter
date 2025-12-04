part of 'AuthBloc.dart';


abstract class AuthEvent {}


class AuthLoginEvent extends AuthEvent {
  final String emailOrUsername;
  final String password;

  AuthLoginEvent({
    required this.emailOrUsername,
    required this.password,
  });
}

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


class AuthCheckEvent extends AuthEvent {}


class AuthLogoutEvent extends AuthEvent {}
