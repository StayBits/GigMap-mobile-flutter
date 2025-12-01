import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../models/PostDataModel.dart';
import '../../repository/PostRepository.dart';

part 'PostEvent.dart';
part 'PostState.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitialState()) {
    on<FetchPostsEvent>(fetchPostsEvent);
    on<CreatePostEvent>(createPostEvent);
    on<LikePostEvent>(likePostEvent);
    on<UnlikePostEvent>(unlikePostEvent);
    on<DeletePostEvent>(deletePostEvent);
    on<UpdatePostEvent>(updatePostEvent);
  }


  Future<void> fetchPostsEvent(
      FetchPostsEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());

    List<PostDataModel> posts = await PostRepository.fetchPosts();
    emit(PostFetchSuccessState(posts: posts));
  }

  Future<void> createPostEvent(
      CreatePostEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());

    PostDataModel? newPost = await PostRepository.createPost(
      communityId: event.communityId,
      userId: event.userId,
      content: event.content,
      image: event.image,
    );

    if (newPost != null) {
      emit(PostCreatedSuccessState(post: newPost));
    } else {
      emit(PostErrorState(message: "Error al crear el post."));
    }
  }

  Future<void> likePostEvent(
      LikePostEvent event, Emitter<PostState> emit) async {
    bool ok = await PostRepository.likePost(event.postId);

    if (ok) {
      emit(PostLikeSuccessState(postId: event.postId));
    } else {
      emit(PostErrorState(message: "Error al hacer like."));
    }
  }

  Future<void> unlikePostEvent(
      UnlikePostEvent event, Emitter<PostState> emit) async {
    bool ok = await PostRepository.unlikePost(event.postId);

    if (ok) {
      emit(PostUnlikeSuccessState(postId: event.postId));
    } else {
      emit(PostErrorState(message: "Error al quitar like."));
    }
  }


  Future<void> deletePostEvent(
      DeletePostEvent event, Emitter<PostState> emit) async {
    bool ok = await PostRepository.deletePost(event.postId);

    if (ok) {
      emit(PostDeletedSuccessState(postId: event.postId));
    } else {
      emit(PostErrorState(message: "Error al eliminar post."));
    }
  }

  Future<void> updatePostEvent(
      UpdatePostEvent event, Emitter<PostState> emit) async {
    emit(PostLoadingState());

    PostDataModel? updated = await PostRepository.updatePost(
      postId: event.postId,
      content: event.content,
      image: event.image,
    );

    if (updated != null) {
      emit(PostUpdatedSuccessState(post: updated));
    } else {
      emit(PostErrorState(message: "Error al actualizar el post."));
    }
  }
}