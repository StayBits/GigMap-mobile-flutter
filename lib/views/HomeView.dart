import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/concerts/ConcertsBloc.dart';
import '../bloc/users/UsersBloc.dart';
import '../bloc/posts/PostBloc.dart';
import '../bloc/m1au/M1AUBloc.dart';
import '../models/UserDataModel.dart';
import '../models/PostDataModel.dart';
import '../models/ConcertDataModel.dart';
import 'ConcertList.dart';
import 'ConcertDetailView.dart';
import 'M1AUChatModal.dart';
import 'HomeShell.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ConcertsBloc concertsBloc = ConcertsBloc();
  final UsersBloc usersBloc = UsersBloc();
  final PostBloc postBloc = PostBloc();
  final M1AUBloc m1auBloc = M1AUBloc();

  List<UserDataModel> _allUsers = [];
  bool _isChatOpen = false;

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
    m1auBloc.close();
    super.dispose();
  }

  void _toggleChat() {
    setState(() => _isChatOpen = !_isChatOpen);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<M1AUBloc>.value(
      value: m1auBloc,
      child: Scaffold(
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

        body: Stack(
          children: [
            MultiBlocListener(
              listeners: [
                BlocListener<UsersBloc, UsersState>(
                  bloc: usersBloc,
                  listener: (_, state) {
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
                    _buildConcertHeader(),
                    _buildConcertCarouselSection(),
                    const SizedBox(height: 20),

                    _buildArtistHeader(),
                    _buildArtistCarouselSection(),

                    const SizedBox(height: 20),
                    _buildPostsSection(),
                  ],
                ),
              ),
            ),


            if (_isChatOpen)
              M1AUChatModal(
                onClose: _toggleChat,


                onNavigateToArtist: (artistId) {
                  final parsedId = int.tryParse(artistId);
                  if (parsedId == null) {
                    debugPrint("artistId inválido: $artistId");
                    _toggleChat();
                    return;
                  }

                  _toggleChat();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeShell(
                        initialIndex: 3,
                        profileUserId: parsedId,
                      ),
                    ),
                  );
                },

                onNavigateToConcert: (concertId) {
                  final parsedId = int.tryParse(concertId);
                  if (parsedId == null) {
                    debugPrint("concertId inválido: $concertId");
                    _toggleChat();
                    return;
                  }

                  _toggleChat();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: concertsBloc,
                        child: ConcertDetailView(concertId: parsedId),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: const Color(0xFF5C0F1A),
            child: Icon(
              _isChatOpen ? FontAwesomeIcons.cat : Icons.catching_pokemon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildConcertHeader() {
    return Padding(
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
            icon: const Icon(Icons.arrow_forward, color: Color(0xFF5C0F1A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Concertlist()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConcertCarouselSection() {
    return BlocBuilder<ConcertsBloc, ConcertState>(
      bloc: concertsBloc,
      builder: (_, state) {
        if (state is ConcertFetchingSuccessFullState) {
          return _concertCarousel(state.concerts);
        }
        return const SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF5C0F1A)),
          ),
        );
      },
    );
  }

  Widget _concertCarousel(List<ConcertDataModel> concerts) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: concerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = concerts[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: concertsBloc,
                    child: ConcertDetailView(concertId: c.id!),
                  ),
                ),
              );
            },
            child: _concertCard(c),
          );
        },
      ),
    );
  }

  Widget _concertCard(ConcertDataModel c) {
    return SizedBox(
      width: 280,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.network(c.image, fit: BoxFit.cover, width: double.infinity),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
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
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildArtistHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, bottom: 10),
      child: Text(
        "Nuevos artistas en GigMap",
        style: TextStyle(
          color: Color(0xFF5C0F1A),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildArtistCarouselSection() {
    return BlocBuilder<UsersBloc, UsersState>(
      bloc: usersBloc,
      builder: (_, state) {
        if (state is UsersFetchingSuccessState) {
          final artists = state.users.where((u) =>
          u.isArtist == true || (u.role ?? '').toUpperCase() == "ARTIST",
          ).toList();

          if (artists.isEmpty) return _emptyBox("No hay artistas aún");

          return _artistCarousel(artists);
        }
        return _emptyBox("Cargando artistas...");
      },
    );
  }

  Widget _artistCarousel(List<UserDataModel> artists) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) {
          final a = artists[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeShell(
                    initialIndex: 3,
                    profileUserId: a.id,
                  ),
                ),
              );
            },
            child: _artistCard(a),
          );
        },
      ),
    );
  }

  Widget _artistCard(UserDataModel a) {
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
  }


  Widget _buildPostsSection() {
    return BlocBuilder<PostBloc, PostState>(
      bloc: postBloc,
      builder: (_, state) {
        if (state is PostFetchSuccessState) {
          final userMap = {for (var u in _allUsers) u.id: u};

          return Column(
            children: state.posts.map((p) {
              final postOwner = userMap[p.userId];

              return GestureDetector(
                onTap: () {
                  if (postOwner != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeShell(
                          initialIndex: 3,
                          profileUserId: postOwner.id,
                        ),
                      ),
                    );
                  }
                },
                child: _postCard(p, postOwner),
              );
            }).toList(),
          );
        }

        return _emptyBox("Cargando publicaciones...");
      },
    );
  }

  Widget _postCard(PostDataModel p, UserDataModel? u) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFF7F7F7),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(u?.image ?? ""),
                ),
                const SizedBox(width: 10),
                Text(
                  u?.username ?? "Usuario",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(p.content, style: const TextStyle(fontSize: 14)),

            if (p.image != null && p.image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    p.image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
