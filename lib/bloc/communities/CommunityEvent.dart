part of 'CommunityBloc.dart';

abstract class CommunityEvent {}


class FetchCommunitiesEvent extends CommunityEvent {}


class FetchUserCommunitiesEvent extends CommunityEvent {
  final int userId;

  FetchUserCommunitiesEvent({required this.userId});
}


class FetchCommunityByIdEvent extends CommunityEvent {
  final int communityId;

  FetchCommunityByIdEvent({required this.communityId});
}


class CreateCommunityEvent extends CommunityEvent {
  final String name;
  final String description;
  final String image;

  CreateCommunityEvent({
    required this.name,
    required this.description,
    required this.image,
  });
}


class UpdateCommunityEvent extends CommunityEvent {
  final int id;
  final String name;
  final String description;
  final String image;

  UpdateCommunityEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });
}


class DeleteCommunityEvent extends CommunityEvent {
  final int id;

  DeleteCommunityEvent({required this.id});
}


class JoinCommunityEvent extends CommunityEvent {
  final int communityId;
  final int userId;

  JoinCommunityEvent({
    required this.communityId,
    required this.userId,
  });
}


class LeaveCommunityEvent extends CommunityEvent {
  final int communityId;
  final int userId;

  LeaveCommunityEvent({
    required this.communityId,
    required this.userId,
  });
}
