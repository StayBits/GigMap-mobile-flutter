import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/bloc/auth/AuthBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/communities/CommunityBloc.dart';
import 'package:gigmap_mobile_flutter/components/GigmapAppBar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/bloc/users/UsersBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/concerts/ConcertsBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/posts/PostBloc.dart';
import 'package:gigmap_mobile_flutter/models/UserDataModel.dart';
import 'package:gigmap_mobile_flutter/services/TokenStorage.dart';
import 'package:gigmap_mobile_flutter/views/edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  final int? userId;

  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UsersBloc _usersBloc;
  late ConcertsBloc _concertsBloc;
  late PostBloc _postBloc;
  late CommunityBloc _communityBloc;

  late int _selectedTab;
  int? _targetUserId;

  UserDataModel? user;
  bool isOwner = false;
  bool isArtist = false;
  bool showArrowBack = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;

    _usersBloc = UsersBloc();
    _concertsBloc = ConcertsBloc();
    _postBloc = PostBloc();
    _communityBloc = CommunityBloc();

    _initData();
  }

  Future<void> _initData() async {
    if (widget.userId != null) {
      _targetUserId = widget.userId;
      final currentId = await TokenStorage.getUserId();
      isOwner = (currentId == _targetUserId);
      showArrowBack = true;
    } else {
      final currentId = await TokenStorage.getUserId();
      _targetUserId = currentId;
      isOwner = true;
    }

    if (_targetUserId != null) {
      _usersBloc.add(FetchUserByIdEvent(userId: _targetUserId!));
      _concertsBloc.add(FetchConcertsByArtistEvent(_targetUserId!));
      _communityBloc.add(FetchUserCommunitiesEvent(userId: _targetUserId!));
      _postBloc.add(FetchPostsEvent());
    }

    setState(() {});
  }

  @override
  void dispose() {
    _usersBloc.close();
    _concertsBloc.close();
    _postBloc.close();
    _communityBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tabs = isArtist
        ? ["Conciertos", "Comunidades", "Posts"]
        : ["GigList", "Comunidades", "Posts"];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: _selectedTab,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UsersBloc>.value(value: _usersBloc),
          BlocProvider<ConcertsBloc>.value(value: _concertsBloc),
          BlocProvider<PostBloc>.value(value: _postBloc),
          BlocProvider<CommunityBloc>.value(value: _communityBloc),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLogoutSuccessActionState) {
              Navigator.pushReplacementNamed(context, "/welcome");
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: GigMapAppBar(
              context: context,
              showBackButton: showArrowBack,
              title: "Perfil",
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    if (isOwner)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                context.read<AuthBloc>().add(AuthLogoutEvent()),
                            child: const Icon(
                              Icons.logout,
                              color: Color(0xFF5C0F1A),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8.0),
                    BlocBuilder<UsersBloc, UsersState>(
                      builder: (context, usersState) {
                        if (usersState is UserByIdSuccessState) {
                          user = usersState.user;

                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color(0xFFEDEDED),
                                backgroundImage: user!.image.isNotEmpty
                                    ? NetworkImage(user!.image)
                                    : null,
                                child: user!.image.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 55,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                user!.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                              ),
                              Text(
                                "@${user!.username}",
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              ElevatedButton(
                                onPressed: () {
                                  if (isOwner) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<UsersBloc>(),
                                          child: EditProfileView(user: user!),
                                        ),
                                      ),
                                    ).then((updated) {
                                      if (updated == true) {
                                        _usersBloc.add(
                                          FetchUserByIdEvent(userId: user!.id),
                                        );
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5C0F1A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  isOwner ? "Editar perfil" : "Seguir",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              TabBar(
                                indicatorColor: const Color(0xFF5C0F1A),
                                labelColor: const Color(0xFF5C0F1A),
                                unselectedLabelColor: Colors.grey,
                                onTap: (index) {
                                  setState(() {
                                    _selectedTab = index;
                                  });
                                },
                                tabs:
                                    (user!.isArtist
                                            ? [
                                                "Conciertos",
                                                "Comunidades",
                                                "Posts",
                                              ]
                                            : [
                                                "GigList",
                                                "Comunidades",
                                                "Posts",
                                              ])
                                        .map((title) => Tab(text: title))
                                        .toList(),
                              ),
                            ],
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    const SizedBox(height: 12.0),
                    // -------- TAB CONTENT --------
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.43,
                      child: TabBarView(
                        children: [
                          // TAB 1 - Conciertos o GigList
                          BlocBuilder<ConcertsBloc, ConcertState>(
                            builder: (context, concertState) {
                              List concerts = [];
                              if (concertState
                                  is ConcertFetchingSuccessFullState) {
                                concerts = concertState.concerts;
                              }
                              if (concerts.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No hay conciertos",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                itemCount: concerts.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12.0),
                                itemBuilder: (context, index) {
                                  final concert = concerts[index];
                                  return Card(
                                    elevation: 4.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: () {},
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(16.0),
                                                ),
                                            child: Image.network(
                                              concert.image ?? '',
                                              height: 160.0,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: 160.0,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  concert.name ?? 'Concierto',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5C0F1A),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  concert.venue?.name ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xFF736D6D),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                                const SizedBox(height: 2.0),
                                                Text(
                                                  ((concert.date ?? '')
                                                                  .toString()
                                                                  .length >=
                                                              10
                                                          ? (concert.date ?? '')
                                                                .toString()
                                                                .substring(
                                                                  0,
                                                                  10,
                                                                )
                                                          : (concert.date ?? '')
                                                                .toString())
                                                      .replaceAll('-', '/'),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          // TAB 2 - Comunidades
                          BlocBuilder<CommunityBloc, CommunityState>(
                            builder: (context, communityState) {
                              List communities = [];
                              if (communityState is CommunityListSuccessState) {
                                communities = communityState.communities;
                              }
                              if (communities.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No hay comunidades",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                itemCount: communities.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final community = communities[index];
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: Image.network(
                                            community.image,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  height: 150,
                                                  color: Colors.grey.shade300,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                community.name.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                community.description,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          // TAB 3 - Likes (CON FETCH USER)
                          BlocBuilder<PostBloc, PostState>(
                            builder: (_, state) {
                              if (user == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (state is PostFetchSuccessState &&
                                  state.posts.isNotEmpty) {
                                final filteredPosts = state.posts
                                    .where((post) => post.userId == user!.id)
                                    .toList();

                                return ListView.separated(
                                  itemCount: filteredPosts.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 12),
                                  itemBuilder: (_, i) => Card(
                                    elevation: 2,
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                backgroundImage:
                                                    user!.image.isNotEmpty
                                                    ? NetworkImage(user!.image)
                                                    : null,
                                                child: (user!.image.isEmpty)
                                                    ? Icon(
                                                        Icons.person,
                                                        color: Colors.grey,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "@${user!.username}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(filteredPosts[i].content),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const Center(
                                child: Text("No hay publicaciones"),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
