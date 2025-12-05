import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../models/CommunityDataModel.dart';
import '../../repository/CommunityRepository.dart';

part 'CommunityEvent.dart';
part 'CommunityState.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(CommunityInitialState()) {
    on<FetchCommunitiesEvent>(fetchCommunitiesEvent);
    on<FetchCommunityByIdEvent>(fetchCommunityByIdEvent);
    on<FetchUserCommunitiesEvent>(fetchUserCommunitiesEvent);

    on<CreateCommunityEvent>(createCommunityEvent);
    on<UpdateCommunityEvent>(updateCommunityEvent);
    on<DeleteCommunityEvent>(deleteCommunityEvent);

    on<JoinCommunityEvent>(joinCommunityEvent);
    on<LeaveCommunityEvent>(leaveCommunityEvent);
  }


  Future<void> fetchCommunitiesEvent(
      FetchCommunitiesEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final communities = await CommunityRepository.fetchCommunities();

    emit(CommunityListSuccessState(communities: communities));
  }


  Future<void> fetchUserCommunitiesEvent(
      FetchUserCommunitiesEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final communities =
    await CommunityRepository.fetchCommunitiesByUser(event.userId);

    emit(CommunityListSuccessState(communities: communities));
  }


  Future<void> fetchCommunityByIdEvent(
      FetchCommunityByIdEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final community =
    await CommunityRepository.fetchCommunityById(event.communityId);

    if (community != null) {
      emit(CommunityDetailSuccessState(community: community));
    } else {
      emit(CommunityErrorState(message: "No se pudo obtener la comunidad."));
    }
  }


  Future<void> createCommunityEvent(
      CreateCommunityEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final community = await CommunityRepository.createCommunity(
      name: event.name,
      description: event.description,
      image: event.image,
    );

    if (community != null) {
      emit(CommunityCreatedSuccessState(community: community));
    } else {
      emit(CommunityErrorState(message: "Error al crear la comunidad."));
    }
  }


  Future<void> updateCommunityEvent(
      UpdateCommunityEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final ok = await CommunityRepository.updateCommunity(
      id: event.id,
      name: event.name,
      description: event.description,
      image: event.image,
    );

    if (ok) {
      emit(CommunityUpdatedSuccessState(
        id: event.id,
        name: event.name,
        description: event.description,
        image: event.image,
      ));
    } else {
      emit(CommunityErrorState(message: "Error al actualizar la comunidad."));
    }
  }


  Future<void> deleteCommunityEvent(
      DeleteCommunityEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final ok = await CommunityRepository.deleteCommunity(event.id);

    if (ok) {
      emit(CommunityDeletedSuccessState(id: event.id));
    } else {
      emit(CommunityErrorState(message: "Error al eliminar la comunidad."));
    }
  }


  Future<void> joinCommunityEvent(
      JoinCommunityEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final ok = await CommunityRepository.joinCommunity(
      communityId: event.communityId,
      userId: event.userId,
    );

    if (ok) {
      emit(CommunityJoinSuccessState(
        communityId: event.communityId,
        userId: event.userId,
      ));
    } else {
      emit(CommunityErrorState(message: "Error al unirse a la comunidad."));
    }
  }

  // DELETE: leave
  Future<void> leaveCommunityEvent(
      LeaveCommunityEvent event, Emitter<CommunityState> emit) async {
    emit(CommunityLoadingState());

    final ok = await CommunityRepository.leaveCommunity(
      communityId: event.communityId,
      userId: event.userId,
    );

    if (ok) {
      emit(CommunityLeaveSuccessState(
        communityId: event.communityId,
        userId: event.userId,
      ));
    } else {
      emit(CommunityErrorState(message: "Error al salir de la comunidad."));
    }
  }
}
