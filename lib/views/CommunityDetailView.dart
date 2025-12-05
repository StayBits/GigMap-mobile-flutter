import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/communities/CommunityBloc.dart';
import '../bloc/posts/PostBloc.dart';
import '../bloc/users/UsersBloc.dart';

import '../models/CommunityDataModel.dart';
import '../models/PostDataModel.dart';
import '../models/UserDataModel.dart';
import '../repository/CommunityRepository.dart';
import '../services/TokenStorage.dart';
import '../repository/PostRepository.dart';

import 'CreatePostView.dart';

class CommunityDetailView extends StatefulWidget {
  final int communityId;
  final int? currentUserId;

  const CommunityDetailView({
    super.key,
    required this.communityId,
    this.currentUserId,
  });

  @override
  State<CommunityDetailView> createState() => _CommunityDetailViewState();
}

class _CommunityDetailViewState extends State<CommunityDetailView> {

  final UsersBloc usersBloc = UsersBloc();
  final PostBloc postBloc = PostBloc();
  int? _currentUserId;
  List<UserDataModel> _allUsers = [];

  final Map<int, bool> _localLikedByPostId = {};
  final Map<int, int> _localLikesCount = {};

  bool _hasMembershipChanged = false;

  @override
  void initState() {
    super.initState();
    usersBloc.add(UsersInitialFetchEvent());
    postBloc.add(FetchPostsEvent());
    _loadCurrentUser();
  }


  Future<void> _loadCurrentUser() async {
    final user = await TokenStorage.getUserData();
    print("DEBUG user from TokenStorage in CommunityDetailView: $user");

    if (!mounted) return;

    setState(() {
      _currentUserId = user?.id;
    });

    print("DEBUG _currentUserId after setState: $_currentUserId");
  }



  @override
  void dispose() {
    usersBloc.close();
    postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communityBloc = context.read<CommunityBloc>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasMembershipChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5C0F1A)),
            onPressed: () {
              Navigator.pop(context, _hasMembershipChanged);
            },
          ),
          centerTitle: true,
          title: const Text(
            'GigMap',
            style: TextStyle(
              color: Color(0xFF5C0F1A),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.notifications_none, color: Color(0xFF5C0F1A)),
            ),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<UsersBloc, UsersState>(
              bloc: usersBloc,
              listener: (context, state) {
                if (state is UsersFetchingSuccessState) {
                  setState(() => _allUsers = state.users);
                }
              },
            ),
          ],
          child: BlocBuilder<CommunityBloc, CommunityState>(
            bloc: communityBloc,
            builder: (context, state) {
              CommunityDataModel? community;

              if (state is CommunityDetailSuccessState) {
                if (state.community.id == widget.communityId) {
                  community = state.community;
                }
              } else if (state is CommunityListSuccessState) {
                try {
                  community = state.communities.firstWhere(
                        (c) => c.id == widget.communityId,
                  );
                } catch (_) {
                  community = null;
                }
              }

              if (community == null) {
                if (state is CommunityLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5C0F1A),
                    ),
                  );
                }

                return const Center(child: Text("Comunidad no encontrada"));
              }

              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    _buildHeader(community, communityBloc),
                    _buildTabs(),
                    Expanded(
                      child: _buildPostsTabView(community),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(
      CommunityDataModel community, CommunityBloc communityBloc) {
    final bool isMember = _currentUserId != null &&
        community.members.contains(_currentUserId);

    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            community.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey.shade300),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${community.members.length} miembros",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 26,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: isMember
                                ? Colors.white
                                : const Color(0xFF5C0F1A),
                            backgroundColor: isMember
                                ? Colors.red.withOpacity(0.9)
                                : Colors.white.withOpacity(0.95),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final userId = _currentUserId;
                            print(
                                "DEBUG currentUserId en botón Unirse/Salir: $userId");

                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                  Text("Debes iniciar sesión para continuar."),
                                ),
                              );
                              return;
                            }

                            if (isMember) {
                              final ok = await CommunityRepository
                                  .leaveCommunity(
                                communityId: community.id,
                                userId: userId,
                              );

                              if (ok) {
                                setState(() {
                                  community.members.remove(userId);
                                  _hasMembershipChanged = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Has salido de la comunidad 👋")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "No se pudo salir de la comunidad")),
                                );
                              }
                            } else {
                              final ok =
                              await CommunityRepository.joinCommunity(
                                communityId: community.id,
                                userId: userId,
                              );

                              if (ok) {
                                setState(() {
                                  community.members.add(userId);
                                  _hasMembershipChanged = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Te uniste a la comunidad 😎💜")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "No se pudo unir a la comunidad")),
                                );
                              }
                            }
                          },
                          child: Text(
                            isMember ? "Salir" : "Unirse",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    community.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostView(
                      communityId: community.id,
                    ),
                  ),
                );

                if (created == true) {
                  postBloc.add(FetchPostsEvent());
                }
              },
              backgroundColor: const Color(0xFF5C0F1A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTabs() {
    return const TabBar(
      labelColor: Color(0xFF5C0F1A),
      unselectedLabelColor: Colors.grey,
      indicatorColor: Color(0xFF5C0F1A),
      tabs: [
        Tab(text: "Artista"),
        Tab(text: "Fans"),
      ],
    );
  }


  Widget _buildPostsTabView(CommunityDataModel community) {
    return BlocBuilder<PostBloc, PostState>(
      bloc: postBloc,
      builder: (context, state) {
        if (state is! PostFetchSuccessState) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5C0F1A)),
          );
        }

        final posts = state.posts;


        final Map<int, UserDataModel> userMap = {
          for (final u in _allUsers) u.id: u,
        };


        final communityPosts = posts.where((p) => p.communityId == community.id);


        final artistPosts = communityPosts.where((p) {
          final user = userMap[p.userId];
          return user?.role == "ARTIST";
        }).toList();


        final fanPosts = communityPosts.where((p) {
          final user = userMap[p.userId];
          return user?.role == "FAN";
        }).toList();


        return TabBarView(
          children: [
            _buildPostsList(
              posts: artistPosts,
              emptyText: "El artista no ha publicado aún.",
              userMap: userMap,
            ),
            _buildPostsList(
              posts: fanPosts,
              emptyText: "Aún no hay publicaciones de fans.",
              userMap: userMap,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostsList({
    required List<PostDataModel> posts,
    required String emptyText,
    required Map<int, UserDataModel> userMap,
  }) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            emptyText,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = posts[i];
        final user = userMap[p.userId];
        return _buildPostCard(p, user);
      },
    );
  }


  Widget _buildPostCard(PostDataModel post, UserDataModel? user) {
    final int? currentUserId = _currentUserId;

    final int backendLikesCount = post.likes?.length ?? 0;
    final bool backendIsLiked = currentUserId != null &&
        (post.likes?.contains(currentUserId) ?? false);

    final bool isLiked = _localLikedByPostId[post.id] ?? backendIsLiked;
    final int likesCount = _localLikesCount[post.id] ?? backendLikesCount;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5C0F1A),
                      width: 1.5,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(user?.image ?? ""),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  (user?.name ?? "").isNotEmpty
                      ? user!.name
                      : user?.username ?? "Usuario anónimo",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (post.content.isNotEmpty) ...[
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
              ),
            ],

            if (post.image != null && post.image!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.image!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  '$likesCount ',
                  style: const TextStyle(color: Colors.grey),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.favorite,
                    size: 22,
                    color: isLiked ? Colors.red : const Color(0xFF2A2A2A),
                  ),
                  onPressed: () async {
                    if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Debes iniciar sesión para dar like"),
                        ),
                      );
                      return;
                    }

                    bool ok;
                    if (isLiked) {
                      // ya tiene like -> unlike
                      ok = await PostRepository.unlikePost(post.id, currentUserId);
                    } else {
                      // no tiene like -> like
                      ok = await PostRepository.likePost(post.id, currentUserId);
                    }

                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No se pudo actualizar el like"),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _localLikedByPostId[post.id] = !isLiked;
                      final baseCount =
                          _localLikesCount[post.id] ?? backendLikesCount;
                      _localLikesCount[post.id] =
                      isLiked ? baseCount - 1 : baseCount + 1;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  "Comentarios",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
