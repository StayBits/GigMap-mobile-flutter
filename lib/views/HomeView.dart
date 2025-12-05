import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/views/ConcertList.dart';

import '../components/GigmapBottomBar.dart';

import '../bloc/concerts/ConcertsBloc.dart';
import '../bloc/users/UsersBloc.dart';
import '../bloc/posts/PostBloc.dart';

import '../models/UserDataModel.dart';
import '../models/PostDataModel.dart';
import '../models/ConcertDataModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ConcertsBloc concertsBloc = ConcertsBloc();
  final UsersBloc usersBloc = UsersBloc();
  final PostBloc postBloc = PostBloc();

  int _bottomIndex = 0;

  List<UserDataModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    concertsBloc.add(ConcertInitialFetchEvent());
    usersBloc.add(UsersInitialFetchEvent());
    postBloc.add(FetchPostsEvent());
  }

  @override
  void dispose() {
    concertsBloc.close();
    usersBloc.close();
    postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Descubre nuevos conciertos",
                      style: TextStyle(
                        color: Color(0xFF5C0F1A),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),


                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF5C0F1A),
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Concertlist(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              BlocBuilder<ConcertsBloc, ConcertState>(
                bloc: concertsBloc,
                builder: (context, state) {
                  if (state is ConcertFetchingSuccessFullState) {
                    return _buildConcertCarousel(state.concerts);
                  }
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5C0F1A),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),


              // Sección Artistas

              const Padding(
                padding: EdgeInsets.only(left: 20, bottom: 10),
                child: Text(
                  "Nuevos artistas en GigMap",
                  style: TextStyle(
                    color: Color(0xFF5C0F1A),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),

              BlocBuilder<UsersBloc, UsersState>(
                bloc: usersBloc,
                builder: (context, state) {
                  if (state is UsersFetchingSuccessState) {
                    final artists = state.users.where((u) {
                      final r = (u.role ?? '').toUpperCase();
                      return r == "ARTIST" || u.isArtist == true;
                    }).toList();

                    if (artists.isEmpty) {
                      return _emptyBox("No hay artistas aún");
                    }

                    return _buildArtistCarousel(artists);
                  }

                  return _emptyBox("Cargando artistas...");
                },
              ),

              const SizedBox(height: 20),

              BlocBuilder<PostBloc, PostState>(
                bloc: postBloc,
                builder: (context, state) {
                  if (state is PostFetchSuccessState) {
                    if (state.posts.isEmpty) {
                      return _emptyBox("No hay publicaciones aún");
                    }

                    final userMap = {
                      for (final u in _allUsers) u.id: u,
                    };

                    return Column(
                      children: state.posts
                          .map((p) => _buildPostCard(p, userMap[p.userId]))
                          .toList(),
                    );
                  }

                  return _emptyBox("Cargando publicaciones...");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildConcertCarousel(List<ConcertDataModel> concerts) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: concerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = concerts[i];
          return SizedBox(
            width: 280,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: Stack(
                children: [
                  Image.network(
                    c.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 12,
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtistCarousel(List<UserDataModel> artists) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final a = artists[i];
          return Column(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5C0F1A), width: 2),
                  image: DecorationImage(
                    image: NetworkImage(a.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 80,
                child: Text(
                  a.username,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostCard(PostDataModel post, UserDataModel? user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFF7F7F7),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                    border:
                    Border.all(color: const Color(0xFF5C0F1A), width: 1.5),
                    image: DecorationImage(
                      image: NetworkImage(user?.image ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  (user?.name ?? "").isNotEmpty
                      ? user!.name
                      : user?.username ?? "Usuario anónimo",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                )
              ],
            ),

            const SizedBox(height: 10),

            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),

            if (post.image != null && post.image!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.image!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
