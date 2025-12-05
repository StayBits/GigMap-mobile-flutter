part of 'PostBloc.dart';

abstract class PostState {}

class PostInitialState extends PostState {}

class PostLoadingState extends PostState {}

// FETCH LIST
class PostFetchSuccessState extends PostState {
  final List<PostDataModel> posts;

  PostFetchSuccessState({required this.posts});
}

// CREATE
class PostCreatedSuccessState extends PostState {
  final PostDataModel post;

  PostCreatedSuccessState({required this.post});
}

// LIKE
class PostLikeSuccessState extends PostState {
  final int postId;
  final int userId;

  PostLikeSuccessState({required this.postId, required this.userId});
}

// UNLIKE
class PostUnlikeSuccessState extends PostState {
  final int postId;
  final int userId;

  PostUnlikeSuccessState({required this.postId, required this.userId});
}

// DELETE
class PostDeletedSuccessState extends PostState {
  final int postId;

  PostDeletedSuccessState({required this.postId});
}

// UPDATE
class PostUpdatedSuccessState extends PostState {
  final PostDataModel post;

  PostUpdatedSuccessState({required this.post});
}

// ERROR
class PostErrorState extends PostState {
  final String message;

  PostErrorState({required this.message});
}

class PostLikedFetchSuccessState extends PostState {
  final List<PostDataModel> posts;

  PostLikedFetchSuccessState({required this.posts});
}
