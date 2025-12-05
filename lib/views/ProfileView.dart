import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/users/UsersBloc.dart';
import '../bloc/concerts/ConcertsBloc.dart';
import '../bloc/posts/PostBloc.dart';
import '../services/TokenStorage.dart';
import '../models/UserDataModel.dart';

class ProfileView extends StatefulWidget {
  final int? userId;

  const ProfileView({super.key, this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final UsersBloc usersBloc;
  late final ConcertsBloc concertsBloc;
  late final PostBloc postBloc;

  UserDataModel? user;
  bool isOwner = false;
  bool isArtist = false;
  int? _targetUserId;

  @override
  void initState() {
    super.initState();

    usersBloc = UsersBloc();
    concertsBloc = ConcertsBloc();
    postBloc = PostBloc();

    _initData();
  }

  Future<void> _initData() async {
    if (widget.userId != null) {
      _targetUserId = widget.userId;
      final currentId = await TokenStorage.getUserId();
      isOwner = (currentId == _targetUserId);
    } else {
      final currentId = await TokenStorage.getUserId();
      _targetUserId = currentId;
      isOwner = true;
    }

    if (_targetUserId != null) {
      usersBloc.add(FetchUserByIdEvent(userId: _targetUserId!));
      concertsBloc.add(ConcertInitialFetchEvent());
      postBloc.add(FetchLikedPostsEvent(userId: _targetUserId!));
    }

    setState(() {});
  }

  @override
  void dispose() {
    usersBloc.close();
    concertsBloc.close();
    postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetUserId == null) {
      return const Scaffold(

        body: Center(child: Text("No se pudo obtener el usuario actual")),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: usersBloc),
        BlocProvider.value(value: concertsBloc),
        BlocProvider.value(value: postBloc),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),

        appBar: AppBar(
          title: const Text("Perfil"),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: const BackButton(color: Colors.black),
        ),

        body: Container(

          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (_, state) {
              if (state is UserByIdSuccessState) {
                user = state.user;
                isArtist = user!.isArtist;
                return _buildProfile(user!);
              }

              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF5C0F1A)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(UserDataModel u) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage(u.image),
          ),
          const SizedBox(height: 12),
          Text(
            u.name.isNotEmpty ? u.name : "@${u.username}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text("@${u.username}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          if (isOwner)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C0F1A),
              ),
              child: const Text("Editar perfil"),
            )
          else
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5C0F1A)),
              ),
              child: const Text("Seguir"),
            ),

          const SizedBox(height: 20),
          _buildTabs(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = isArtist ? ["Conciertos", "Likes"] : ["GigList", "Likes"];

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF5C0F1A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF5C0F1A),
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),

          SizedBox(
            height: 400,
            child: TabBarView(
              children: [
                _concertsTab(),
                _likesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _concertsTab() {
    return BlocBuilder<ConcertsBloc, ConcertState>(
      builder: (_, state) {
        if (state is ConcertFetchingSuccessFullState) {
          final concerts = state.concerts;

          final myConcerts = concerts.toList();

          if (myConcerts.isEmpty) {
            return const Center(child: Text("No hay conciertos"));
          }

          return ListView.builder(
            itemCount: myConcerts.length,
            itemBuilder: (_, i) {
              final c = myConcerts[i];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(c.image)),
                title: Text(c.name),
                subtitle: Text(c.venue.name),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _likesTab() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (_, state) {
        if (state is PostLikedFetchSuccessState) {
          if (state.posts.isEmpty) {
            return const Center(child: Text("No hay likes aún"));
          }

          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (_, i) {
              final p = state.posts[i];
              return ListTile(title: Text(p.content));
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
