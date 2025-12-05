import 'dart:async';
import 'package:bloc/bloc.dart';

import 'package:gigmap_mobile_flutter/repository/UserRepository.dart';
import 'package:gigmap_mobile_flutter/models/UserDataModel.dart';

part 'UsersState.dart';
part 'UsersEvent.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {

    on<UsersInitialFetchEvent>(usersInitialFetchEvent);
    on<FetchUserByIdEvent>(fetchUserByIdEvent);
    on<FetchUserDetailsEvent>(fetchUserDetailsEvent);
    on<UpdateUserEvent>(updateUserEvent);

  }

  // Fetch all users
  Future<void> usersInitialFetchEvent(
      UsersInitialFetchEvent event, Emitter<UsersState> emit) async {

    emit(UsersLoadingState());

    List<UserDataModel> users = await UserRepository.fetchUsers();

    emit(UsersFetchingSuccessState(users: users));
  }


  // Fetch user by ID
  Future<void> fetchUserByIdEvent(
      FetchUserByIdEvent event, Emitter<UsersState> emit) async {

    emit(UsersLoadingState());

    UserDataModel? user = await UserRepository.fetchUserById(event.userId);

    if (user != null) {
      emit(UserByIdSuccessState(user: user));
    } else {
      emit(UsersErrorState(message: "Usuario no encontrado"));
    }
  }


  // Fetch user details
  Future<void> fetchUserDetailsEvent(
      FetchUserDetailsEvent event, Emitter<UsersState> emit) async {

    emit(UsersLoadingState());

    var details = await UserRepository.fetchUserDetails(event.userId);

    if (details != null) {
      emit(UserDetailsSuccessState(details: details));
    } else {
      emit(UsersErrorState(message: "No se pudieron obtener los detalles"));
    }
  }


  // Update user
  Future<void> updateUserEvent(
      UpdateUserEvent event, Emitter<UsersState> emit) async {

    emit(UsersLoadingState());

    UserDataModel? updated = await UserRepository.updateUser(
      userId: event.userId,
      email: event.email,
      username: event.username,
      isArtist: event.isArtist,
      role: event.role,
      name: event.name,
      image: event.image,
    );

    if (updated != null) {
      emit(UserUpdatedSuccessState(user: updated));
    } else {
      emit(UsersErrorState(message: "No se pudo actualizar el usuario"));
    }
  }
}
