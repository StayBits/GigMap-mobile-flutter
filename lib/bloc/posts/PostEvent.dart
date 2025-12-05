part of 'PostBloc.dart';

abstract class PostEvent {}

// Fetch all posts
class FetchPostsEvent extends PostEvent {}

// Create
class CreatePostEvent extends PostEvent {
  final int communityId;
  final int userId;
  final String content;
  final String? image;

  CreatePostEvent({
    required this.communityId,
    required this.userId,
    required this.content,
    this.image,
  });
}

// Like
class LikePostEvent extends PostEvent {
  final int postId;
  final int userId;

  LikePostEvent({required this.postId, required this.userId});
}

// Unlike
class UnlikePostEvent extends PostEvent {
  final int postId;
  final int userId;

  UnlikePostEvent({required this.postId, required this.userId});
}

// Delete
class DeletePostEvent extends PostEvent {
  final int postId;

  DeletePostEvent({required this.postId});
}

// Update
class UpdatePostEvent extends PostEvent {
  final int postId;
  final String content;
  final String? image;

  UpdatePostEvent({required this.postId, required this.content, this.image});
}

class FetchLikedPostsEvent extends PostEvent {
  final int userId;

  FetchLikedPostsEvent({required this.userId});
}
