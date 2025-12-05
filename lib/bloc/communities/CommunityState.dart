part of 'CommunityBloc.dart';

abstract class CommunityState {}

class CommunityInitialState extends CommunityState {}

class CommunityLoadingState extends CommunityState {}


class CommunityListSuccessState extends CommunityState {
  final List<CommunityDataModel> communities;

  CommunityListSuccessState({required this.communities});
}


class CommunityDetailSuccessState extends CommunityState {
  final CommunityDataModel community;

  CommunityDetailSuccessState({required this.community});
}


class CommunityCreatedSuccessState extends CommunityState {
  final CommunityDataModel community;

  CommunityCreatedSuccessState({required this.community});
}


class CommunityUpdatedSuccessState extends CommunityState {
  final int id;
  final String name;
  final String description;
  final String image;

  CommunityUpdatedSuccessState({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });
}


class CommunityDeletedSuccessState extends CommunityState {
  final int id;

  CommunityDeletedSuccessState({required this.id});
}


class CommunityJoinSuccessState extends CommunityState {
  final int communityId;
  final int userId;

  CommunityJoinSuccessState({
    required this.communityId,
    required this.userId,
  });
}

// LEAVE
class CommunityLeaveSuccessState extends CommunityState {
  final int communityId;
  final int userId;

  CommunityLeaveSuccessState({
    required this.communityId,
    required this.userId,
  });
}

// ERROR
class CommunityErrorState extends CommunityState {
  final String message;

  CommunityErrorState({required this.message});
}
