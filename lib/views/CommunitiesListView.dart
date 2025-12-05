import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/communities/CommunityBloc.dart';
import '../models/CommunityDataModel.dart';
import '../views/CommunityDetailView.dart';
import 'CreateCommunityView.dart';

import '../services/TokenStorage.dart';
import '../repository/CommunityRepository.dart';

class CommunitiesListView extends StatefulWidget {
  const CommunitiesListView({super.key});

  @override
  State<CommunitiesListView> createState() => _CommunitiesListViewState();
}

class _CommunitiesListViewState extends State<CommunitiesListView> {
  final CommunityBloc communityBloc = CommunityBloc();
  String _searchQuery = '';


  int? _currentUserId;
  List<CommunityDataModel> _followedCommunities = [];

  @override
  void initState() {
    super.initState();
    communityBloc.add(FetchCommunitiesEvent());

    _initUserAndFollowed();
  }

  Future<void> _initUserAndFollowed() async {
    // 1. Obtener usuario logueado
    final user = await TokenStorage.getUserData();

    if (!mounted) return;

    setState(() {
      _currentUserId = user?.id;
    });

    if (_currentUserId == null) return;

    // 2. Traer comunidades que sigue este usuario
    final joined =
    await CommunityRepository.fetchCommunitiesByUser(_currentUserId!);

    if (!mounted) return;

    setState(() {
      _followedCommunities = joined;
    });
  }

  @override
  void dispose() {
    communityBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C0F1A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Comunidades',
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        bloc: communityBloc,
        listenWhen: (prev, curr) => curr is CommunityErrorState,
        buildWhen: (prev, curr) => curr is! CommunityErrorState,
        listener: (context, state) {
          if (state is CommunityErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CommunityLoadingState ||
              state is CommunityInitialState) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C0F1A)),
            );
          }

          if (state is CommunityListSuccessState) {
            return _buildSuccessList(state.communities);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSuccessList(List<CommunityDataModel> communities) {
    final filtered = _searchQuery.isEmpty
        ? communities
        : communities
        .where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 🔹 Carrusel solo con comunidades que SIGO
          _buildTopCarousel(),

          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 12),

          // 🔹 Lista completa de comunidades
          ListView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) => _buildCommunityCard(filtered[index]),
          ),
        ],
      ),
    );
  }

  /// 🔝 Carrusel de arriba: SOLO comunidades que el usuario sigue
  Widget _buildTopCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              // 👉 Botón CREAR (siempre)
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateCommunityView(),
                        ),
                      );

                      if (created == true) {
                        // refrescamos todas
                        communityBloc.add(FetchCommunitiesEvent());
                        // refrescamos las que sigo
                        await _initUserAndFollowed();
                      }
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C0F1A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'CREAR',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _followedCommunities.isEmpty
                    ? const Center(
                  child: Text(
                    "Aún no sigues comunidades",
                    style:
                    TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                )
                    : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _followedCommunities.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final community = _followedCommunities[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: communityBloc,
                              child: CommunityDetailView(
                                communityId: community.id,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          ClipOval(
                            child: Image.network(
                              community.image,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 45,
                                height: 45,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.groups),
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            width: 55,
                            child: Text(
                              community.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar comunidad',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF5C0F1A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF5C0F1A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF5C0F1A)),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard(CommunityDataModel community) {
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: communityBloc,
              child: CommunityDetailView(communityId: community.id),
            ),
          ),
        );

        if (changed == true) {
          communityBloc.add(FetchCommunitiesEvent());
          await _initUserAndFollowed();
        }
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
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
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
