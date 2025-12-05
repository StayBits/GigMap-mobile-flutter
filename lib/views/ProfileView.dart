import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/components/GigmapAppBar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/bloc/auth/AuthBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/users/UsersBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/concerts/ConcertsBloc.dart';
import 'package:gigmap_mobile_flutter/bloc/posts/PostBloc.dart';
import 'package:collection/collection.dart';
import 'package:gigmap_mobile_flutter/services/TokenStorage.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Local blocs so this view can fetch its data independently
  late UsersBloc _usersBloc;
  late ConcertsBloc _concertsBloc;
  late PostBloc _postBloc;

  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;
    _usersBloc = UsersBloc()..add(UsersInitialFetchEvent());
    _concertsBloc = ConcertsBloc()..add(ConcertInitialFetchEvent());
    _postBloc = PostBloc();
    _fetchInitialLikedPosts();
  }

  void _fetchInitialLikedPosts() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      _postBloc.add(FetchLikedPostsEvent(userId: userId));
    }
  }

  void loadFetchLikes() async {
    final userId = await TokenStorage.getUserId();
    print(userId);
    if (userId != null) {
      _postBloc.add(FetchLikedPostsEvent(userId: userId));
    }
  }

  @override
  void dispose() {
    _usersBloc.close();
    _concertsBloc.close();
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = true; // Placeholder for current user vs viewed user
    final bool isArtist = false; // Placeholder for user role
    final String? currentUserImage = ""; // Placeholder
    final String currentUserName = "Nombre de usuario"; // Placeholder
    final String currentUsername = "@username"; // Placeholder

    final List<String> tabOptions = isArtist
        ? ["Conciertos", "Comunidades", "Likes"]
        : ["GigList", "Comunidades", "Likes"];

    return DefaultTabController(
      length: tabOptions.length,
      initialIndex: _selectedTab,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UsersBloc>.value(value: _usersBloc),
          BlocProvider<ConcertsBloc>.value(value: _concertsBloc),
          BlocProvider<PostBloc>.value(value: _postBloc),
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: GigMapAppBar(context: context),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Row below the custom AppBar that shows the title and a trailing action
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        // Keep a simple trailing icon; actual logout/action handled elsewhere
                        const Icon(Icons.more_vert, color: Color(0xFF5C0F1A)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // HEADER: combine AuthBloc + UsersBloc to render real data when available
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      int? userId;
                      if (authState is AuthAuthenticatedState) {
                        userId = authState.user.id;
                      }

                      return BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, usersState) {
                          String name = currentUserName;
                          String username = currentUsername;
                          String? image = currentUserImage;
                          bool owner = isOwner;
                          bool artist = isArtist;

                          if (usersState is UsersFetchingSuccessState) {
                            final users = usersState.users;
                            if (userId != null) {
                              final u = users.firstWhereOrNull(
                                (e) => e.id == userId,
                              );
                              if (u != null) {
                                name = (u.name).isNotEmpty ? u.name : name;
                                username = (u.username).isNotEmpty
                                    ? '@${u.username}'
                                    : username;
                                image = u.image;
                                artist = u.isArtist;
                                owner = true;
                              }
                            }
                          }

                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color(0xFFEDEDED),
                                backgroundImage:
                                    image != null && image.isNotEmpty
                                    ? NetworkImage(image)
                                    : null,
                                child: image == null || image.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 55,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                              ),
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              if (owner)
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C0F1A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Editar perfil",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Seguir",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24.0),

                  // TABS
                  TabBar(
                    indicatorColor: const Color(0xFF5C0F1A),
                    labelColor: const Color(0xFF5C0F1A),
                    unselectedLabelColor: Colors.grey,
                    onTap: (index) {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    tabs: tabOptions.map((title) => Tab(text: title)).toList(),
                  ),

                  const SizedBox(height: 12.0),

                  // CONTENT: use ConcertsBloc + PostBloc to populate lists when available
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      children: [
                        // Tab 0: Conciertos (ARTIST) / GigList (FAN)
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
                                                (context, error, stackTrace) =>
                                                    Container(
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
                                                              .substring(0, 10)
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

                        // Tab 1: Comunidades (static placeholder until community bloc exists)
                        const Center(
                          child: Text(
                            "Comunidades (contenido estático)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        // Tab 2: Likes (use PostBloc if available)
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, postState) {
                            List posts = [];
                            if (postState is PostLikedFetchSuccessState) {
                              posts = postState.posts;
                            }

                            if (posts.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No hay publicaciones en Likes",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              itemCount: posts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12.0),
                              itemBuilder: (context, index) {
                                final post = posts[index];
                                return Card(
                                  elevation: 2.0,
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(''),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              post.userId?.toString() ??
                                                  'Anónimo',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(post.content ?? ''),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
    );
  }
}
