part of 'UsersBloc.dart';

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoadingState extends UsersState {}

// List of users
class UsersFetchingSuccessState extends UsersState {
  final List<UserDataModel> users;

  UsersFetchingSuccessState({required this.users});
}

// Single user by id
class UserByIdSuccessState extends UsersState {
  final UserDataModel user;

  UserByIdSuccessState({required this.user});
}

// User details
class UserDetailsSuccessState extends UsersState {
  final Map<String, dynamic> details;

  UserDetailsSuccessState({required this.details});
}

// After update
class UserUpdatedSuccessState extends UsersState {
  final UserDataModel user;

  UserUpdatedSuccessState({required this.user});
}

// Error
class UsersErrorState extends UsersState {
  final String message;

  UsersErrorState({required this.message});
}
