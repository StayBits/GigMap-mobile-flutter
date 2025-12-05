part of 'UsersBloc.dart';

abstract class UsersEvent {}

class UsersInitialFetchEvent extends UsersEvent {}

class FetchUserByIdEvent extends UsersEvent {
  final int userId;

  FetchUserByIdEvent({required this.userId});
}

class FetchUserDetailsEvent extends UsersEvent {
  final int userId;

  FetchUserDetailsEvent({required this.userId});
}

class UpdateUserEvent extends UsersEvent {
  final int userId;
  final String email;
  final String username;
  final bool isArtist;
  final String? role;
  final String name;
  final String image;

  UpdateUserEvent({
    required this.userId,
    required this.email,
    required this.username,
    required this.isArtist,
    this.role,
    required this.name,
    required this.image
  });
}
